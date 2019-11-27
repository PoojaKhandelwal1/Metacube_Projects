/**
 * Author: Pooja Kahndelwal
 * Since: Jan 31, 2019
 * Name: NotesService
 * Description: Service Class used to perform CRUD operations on Generic Notes Object-Used to store concerns/notes for BP records 
**/
public without sharing class NotesService {
    
    /**
    * Name: upsertNotesRecord
    * Desc: Method to Create/Update Notes record
    * @param: concern - String - cocerns/notes to be saved
    * @param: notesId - Id - Notes Record Id
    * @return: Id - Notes Record Id
    **/
   	public static Id upsertNotesRecord(String concern, Id notesId) {
    	if(String.isBlank(notesId)) {
    		if(AccessControl.ifObjectFieldIsCreateable('Notes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
    	} else {
    		if(AccessControl.ifObjectFieldIsUpdateable('Notes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	}
        
    	Notes__c notes = new Notes__c(Description__c = concern, Id = notesId);
    	upsert notes;
    	if(notes != null) {
    		return notes.Id;
    	} 
    	return '';
    }
    
    /**
    * Name: deleteNotesRecords
    * Desc: Method to Delete Notes record
    * @param: notesIdSet - Set<Id> - Deletable Notes records' Id set
    * @return: 
    **/
    public static void deleteNotesRecords(Set<Id> notesIdSet) {
    	if(AccessControl.ifObjectFieldIsAccessible('Notes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Notes__c> notesRecordList = new List<Notes__c>();
    	for(Id notesId : notesIdSet) {
    		notesRecordList.add(new Notes__c(Id = notesId));
    	}
   		if(AccessControl.ifObjectIsDeletable('Notes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
   		delete notesRecordList;
    }
    
    /**
    * Name: populateNotesLookup
    * Desc: Method to Create/Update Notes record and then Populate Notes Id (Event_Concern__c field) (Notes Lookup) on Event record - while Save Events
    * @param: eventRec - Event - Event record
    * @param: concern - String - Appointment cocerns to be saved
    * @return: Event - eventRec - Event record
    **/
    public static Event populateNotesLookup(Event eventRec, String concern) {
    	String notesId = upsertNotesRecord(concern, null); 
    	if(String.isNotBlank(notesId)) {
    		eventRec.Event_Concern__c = notesId;
    	}
    	return eventRec;
    }
    
    /**
    * Name: populateConcernsOnSO
    * Desc: Method to Populate concern field on SO record from corresponding Event's 'Notes' record - while Save SO
    * @param: soRec - Service_Order_Header__c - SO Record
    * @param: notesId - String - Notes Record Id
    * @return:
    **/
    public static void populateConcernsOnSO(Service_Order_Header__c soRec, String notesId) {
   		if(AccessControl.ifObjectFieldIsAccessible('Notes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Notes__c> notesList = [SELECT Id, Description__c FROM Notes__c WHERE Id =: notesId];
        soRec.SO_Concern__c = '';
        for(Notes__c notesRec : notesList) {
        	soRec.SO_Concern__c += (notesRec.Description__c != null) ? notesRec.Description__c : '';
        }
   	}	
   	
   	/**
    * Name: populateNotesOnAppointment
    * Desc: Method to Populate concern field on AppointmentWrapper Json('Event' Rec) from corresponding 'Notes' record - while get Events  
    * @param: appointmentObj - AppointmentWrapper - Appointment Json
    * @param: notesId - String - Notes Record Id
    * @return:
    **/
   	public static void populateNotesOnAppointment(AppointmentWrapper appointmentObj, String notesId) {
   		if(AccessControl.ifObjectFieldIsAccessible('Notes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Notes__c> notesList = [SELECT Id, Description__c FROM Notes__c WHERE Id =: notesId];
        for(Notes__c notesRec : notesList) {
        	if(String.isNotBlank(notesRec.Description__c)) {
                appointmentObj.Concern.addAll(notesRec.Description__c.split('\n'));
            }
        }
   	}
}