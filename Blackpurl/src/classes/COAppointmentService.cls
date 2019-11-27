/**
 * Author: Pooja Kahndelwal
 * Since: Sep 09, 2018
 * Name: COAppointmentService
 * Description: Service Class used to perform CRUD operations on CO Appoinments
**/
public without sharing class COAppointmentService {

   	public static Map<Id, AppointmentWrapper> getAppointmentsBySectionId(String sectionId) {
    	String sectionName = BPUtility.getSectionNameBySectionId(sectionId);
        if(String.isBlank(sectionName)) {
        	return new Map<Id, AppointmentWrapper>();
        }
        
        List<Id> sectionIdList = new List<Id>();
        if(sectionName == 'All') {
        	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    		List<Service_Order_Header__c> soHeaderList = [SELECT Id FROM Service_Order_Header__c WHERE CO_Header__c =: sectionId];
    		for(Service_Order_Header__c soHeaderRec : soHeaderList) {
        		sectionIdList.add(soHeaderRec.Id);
        	}
        } else {
        	sectionIdList.add(sectionId);
        }
        
        List<Event> appointmentList = SchedulerSOQLUtil.getAppointmentListBySOId(sectionIdList);
        Map<Id, AppointmentWrapper> sectionIdToAppointmentRecMap = getSectionIdToAppointmentRecMap(appointmentList);
       	return sectionIdToAppointmentRecMap;
   	}
   	
   	private static Map<Id, AppointmentWrapper> getSectionIdToAppointmentRecMap(List<Event> appointmentList) {
   		Map<Id, AppointmentWrapper> sectionIdToAppointmentRecMap = new Map<Id, AppointmentWrapper>();
    	for(Event eventRec : appointmentList) {
   			if(String.isNotBlank(eventRec.Service_Order_Header__c)) {
   				AppointmentWrapper appointmentRec = new AppointmentWrapper(eventRec, true);
   				AppointmentService.populateSOKitConcernsOnAppointment(appointmentRec, eventRec.Service_Order_Header__c);
   				if(String.isNotBlank(eventRec.Event_Concern__c)) {
	   				NotesService.populateNotesOnAppointment(appointmentRec, eventRec.Event_Concern__c);
	   			}	   			
	   			sectionIdToAppointmentRecMap.put(eventRec.Service_Order_Header__c, appointmentRec);
   			}
	   	}
   		return sectionIdToAppointmentRecMap;
   	}
   	
   	public static void updateAppointmentsBySectionId(String sectionId) {
        String sectionName = BPUtility.getSectionNameBySectionId(sectionId);
        if(String.isBlank(sectionName)) {
        	return;
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String query = 'SELECT Id, CO_Header__r.Customer__c, Service_Order_Header__r.Customer_Owned_Unit__c, Service_Order_Header__r.Name__c, Service_Order_Header__r.Transaction_Type__c, Service_Order_Header__r.SO_Concern__c, Event_Concern__c FROM Event';
        if(sectionName == 'All') {
    		query += ' WHERE CO_Header__c =: sectionId';
        } else {
        	query += ' WHERE Service_Order_Header__c =: sectionId';
        }
        List<Event> eventList = Database.query(query);
        Set<Id> deletableNotesIdSet;
        
        for(Event eventRec : eventList) {
    		eventRec.Customer__c = eventRec.CO_Header__r.Customer__c;
    		eventRec.Customer_Owned_Unit__c = eventRec.Service_Order_Header__r.Customer_Owned_Unit__c;
    		eventRec.Subject = eventRec.Service_Order_Header__r.Name__c;
    		eventRec.Transaction_Type__c = eventRec.Service_Order_Header__r.Transaction_Type__c;
    		eventRec.Appointment_Concern__c = eventRec.Service_Order_Header__r.SO_Concern__c;
            
    		if(String.isNotBlank(eventRec.Service_Order_Header__r.SO_Concern__c) && eventRec.Service_Order_Header__r.SO_Concern__c.length() > 255) {
            	eventRec.Appointment_Concern__c = '';
            	if(String.isNotBlank(eventRec.Event_Concern__c)) {
            		NotesService.upsertNotesRecord(eventRec.Service_Order_Header__r.SO_Concern__c, eventRec.Event_Concern__c); 
            	} else {
            		eventRec = NotesService.populateNotesLookup(eventRec, eventRec.Service_Order_Header__r.SO_Concern__c);
            	}
	        } else {
	        	if(String.isNotBlank(eventRec.Event_Concern__c)) {
	        		deletableNotesIdSet = new Set<Id>();
	        		deletableNotesIdSet.add(eventRec.Event_Concern__c);
	        	}
	        	eventRec.Appointment_Concern__c = eventRec.Service_Order_Header__r.SO_Concern__c;
	        }
    	}
        
        if(eventList.size() > 0) {
        	if(AccessControl.ifObjectFieldIsUpdateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        	update eventList;
        }
        
        if(deletableNotesIdSet != null && deletableNotesIdSet.size() > 0) {
        	NotesService.deleteNotesRecords(deletableNotesIdSet);
        }
   	}
}