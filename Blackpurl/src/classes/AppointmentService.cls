public without sharing class AppointmentService {
    
    private static final String CONST_APPOINTMENT = 'Appointment';
    
    /**
    * Name: saveAppointment
    * Desc: Method to save a appointment
    * @param: Appointment data
    **/
    public static void saveAppointment(String appointmentDetailJSON) {
        AppointmentWrapper appointmentDetailObj = (AppointmentWrapper)System.JSON.deserialize(appointmentDetailJSON, AppointmentWrapper.class);
        Event eventRec = new Event(Id = appointmentDetailObj.Id);
        eventRec.Type = CONST_APPOINTMENT;
        eventRec.Customer__c = appointmentDetailObj.CustomerId;
        eventRec.Customer_Owned_Unit__c = appointmentDetailObj.COUId;
        eventRec.Estimated_Hours__c = appointmentDetailObj.EstimatedHours;
        eventRec.Transaction_Type__c = appointmentDetailObj.TransactionTypeId;
        eventRec.Subject = String.isNotBlank(appointmentDetailObj.Title) ? appointmentDetailObj.Title : 'no title';
        eventRec.CO_Header__c = appointmentDetailObj.COId;
        eventRec.Service_Order_Header__c = appointmentDetailObj.SOHeaderId;
        eventRec.Technician__c = appointmentDetailObj.TechnicianId;
        if(String.isNotBlank(appointmentDetailObj.StartTime)) {
            if(appointmentDetailObj.StartTime.toLowerCase().contains('am')) {
                eventRec.Appointment_Day_Segment__c = 'Morning'; 
            } else if(appointmentDetailObj.StartTime.toLowerCase().contains('pm')){
                eventRec.Appointment_Day_Segment__c = 'Afternoon';
            }
        }
        
        String concern = BPUtility.convertListIntoString(appointmentDetailObj.Concern);
        Set<Id> deletableNotesIdSet;
        
        if(eventRec.Id != null) {
            List<Event> eventList = [Select StartDateTime, Event_Concern__c from Event where Id =: eventRec.Id];
            if(eventList.size() > 0) {
                DateTime startDt = DateTimeUtility.getConvertedDateTime(appointmentDetailObj.StartDate, appointmentDetailObj.StartTime);
                eventRec = setStartEndDate(eventRec, appointmentDetailObj);
                if(String.isNotBlank(concern) && concern.length() > 255) {
                    eventRec.Appointment_Concern__c = '';
                    if(String.isNotBlank(eventList[0].Event_Concern__c)) {
                        NotesService.upsertNotesRecord(concern, eventList[0].Event_Concern__c); 
                    } else {
                        eventRec = NotesService.populateNotesLookup(eventRec, concern);
                    }
                } else {
                    if(String.isNotBlank(eventList[0].Event_Concern__c)) {
                        deletableNotesIdSet = new Set<Id>();
                        deletableNotesIdSet.add(eventList[0].Event_Concern__c);
                    }
                    eventRec.Appointment_Concern__c = concern;
                }
            }
        } else {
            eventRec = setStartEndDate(eventRec, appointmentDetailObj);
	        if(String.isNotBlank(concern) && concern.length() > 255) {
                eventRec = NotesService.populateNotesLookup(eventRec, concern);
            } else {
                eventRec.Appointment_Concern__c = concern;
            }
        }
        upsert eventRec;
        
    	if(appointmentDetailObj.isConflictExists != null && appointmentDetailObj.isConflictExists) {
        	reshuffleConflictedAppointments(eventRec.Id, appointmentDetailObj.StartDate);
        }
        if(deletableNotesIdSet != null && deletableNotesIdSet.size() > 0) {
            NotesService.deleteNotesRecords(deletableNotesIdSet);
        }
        
        //To create Customer Order for appointment
        if(String.isBlank(appointmentDetailObj.COId) && String.isNotBlank(appointmentDetailObj.TechnicianId)) {
            appointmentDetailObj.Id = eventRec.Id;
            String coHeaderId = JobSchedulerService.createCOWithServiceJob(system.Json.serialize(appointmentDetailObj));
        }
        
        updateRelatedSORecord(eventRec.Id);
    }
    
    public static void reshuffleConflictedAppointments(String appointmentId, String appointmentDate) {
        List<Event> appointmentRecList = SchedulerSOQLUtil.getAppointmentWithIds(new Set<String>{appointmentId});
        if(appointmentRecList.size() > 0) {
            Event bookedAppointment = appointmentRecList[0];
            DateTime selectedDate = HomeSearchFilterInterface.getDateFromString(appointmentDate);
            Map<String, List<String>> queryParamMap = new Map<String, List<String>>{
                            'Id' => new List<String>{'!=', bookedAppointment.Id},
                            'Technician__c' => new List<String>{'=', bookedAppointment.Technician__c}
               };
            List<Event> conflictedAppointmentList = SchedulerSOQLUtil.getAppoitmentList(queryParamMap, selectedDate);
            
            DateTime updatedAppointmentStartTime = bookedAppointment.StartDateTime;
            DateTime updatedAppointmentEndTime = (bookedAppointment.EndDateTime != null) ? bookedAppointment.EndDateTime : 
                                                        updatedAppointmentStartTime.addMinutes((Integer) (bookedAppointment.Estimated_Hours__c * 60));
            
            List<Event> conflictedAppointmentToUpdateList = new List<Event>();
            for(Event conflictAppointmentRec : conflictedAppointmentList) {
                if(updatedAppointmentStartTime <= conflictAppointmentRec.StartDateTime && conflictAppointmentRec.StartDateTime < updatedAppointmentEndTime) {
                    
                    updatedAppointmentStartTime = conflictAppointmentRec.StartDateTime = updatedAppointmentEndTime;
                    updatedAppointmentEndTime = conflictAppointmentRec.EndDateTime = 
                                    conflictAppointmentRec.StartDateTime.addMinutes((Integer) (conflictAppointmentRec.Estimated_Hours__c * 60));
                    conflictedAppointmentToUpdateList.add(conflictAppointmentRec);
                }
            }            
            if(conflictedAppointmentToUpdateList.size() > 0) {
                update conflictedAppointmentToUpdateList;
            }
        } 
    }
    
    private static Event setStartEndDate(Event eventRec, AppointmentWrapper appointmentDetailObj) {
        if(String.isNotBlank(appointmentDetailObj.StartDate) && String.isNotBlank(appointmentDetailObj.StartTime)) {
            eventRec.StartDateTime = DateTimeUtility.getConvertedDateTime(appointmentDetailObj.StartDate, appointmentDetailObj.StartTime);
            if(appointmentDetailObj.EstimatedHours != null && appointmentDetailObj.EstimatedHours > 0) {
	        	eventRec.EndDateTime = eventRec.StartDateTime.addMinutes((Integer) (appointmentDetailObj.EstimatedHours * 60));
        }
        }
        if(eventRec.EndDateTime == null && String.isNotBlank(appointmentDetailObj.EndDate) && String.isNotBlank(appointmentDetailObj.EndTime)) {
            eventRec.EndDateTime = DateTimeUtility.getConvertedDateTime(appointmentDetailObj.EndDate, appointmentDetailObj.EndTime);
        }
        if(eventRec.StartDateTime != null && eventRec.EndDateTime != null && !eventRec.StartDateTime.isSameDay(eventRec.EndDateTime)) {
            eventRec.IsMultiDayEvent__c = true;
        }
        return eventRec; 
    }
    
    public static CustomerWrapper getCustomerRecByCustomerId(String customerId) {
        List<Account> customerRecList = SOQLUtil.getCustomer(customerId, 'Customer', true, ('Status__c = \'Active\''));
        CustomerWrapper customerWrapperObj;
        if(customerRecList.size() > 0) {
            customerWrapperObj = new CustomerWrapper(customerRecList[0], customerRecList[0].Customer_Owned_Units__r);
        }
        return customerWrapperObj;
    }
    
    public static CustomerOwnedUnit getUnitById(String couId) {
        List<Sobject> unitRecList = SOQLUtil.getCOUListByFieldName('Id', couId);
        CustomerOwnedUnit unitObj;
        if(unitRecList.size() > 0) {
            unitObj = new CustomerOwnedUnit((Customer_Owned_Unit__c) unitRecList[0]);
        }
        return unitObj;
    }
    
    public static String deleteAppointmentById(String appointmentRecId){
        if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Event> eventList = [Select Id, Event_Concern__c from Event where Id =: appointmentRecId];
        Set<Id> deletableNotesIdSet = new Set<Id>();
        for(Event event : eventList) {
            if(String.isNotBlank(event.Event_Concern__c)) {
                deletableNotesIdSet.add(event.Event_Concern__c);
            }
        }
        
        if(AccessControl.ifObjectIsDeletable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete new Event(Id = appointmentRecId);
        
        if(deletableNotesIdSet.size() > 0) {
            NotesService.deleteNotesRecords(deletableNotesIdSet);
        }
        return 'SUCCESS';
    }
    
    public static List<ServiceOrderWrapper.TTType> getJobTypeList(){
        List<Transaction_Type__c> ttList = SOQLUtil.getTransactionTypesWithProvider(new List<Id>());
        ttList = ServiceJobTypeService.sortJobTypes(ttList);
        List<ServiceOrderWrapper.TTType> jobTypeList = new List<ServiceOrderWrapper.TTType>();
        for(Transaction_Type__c ttRec: ttList) {
            jobTypeList.add(new ServiceOrderWrapper.TTType(ttRec));
        }
        return jobTypeList;
    }
    
    private static void updateRelatedSORecord(String appointmentRecId) {
        if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Event> eventList = [SELECT Id, Service_Order_Header__c, Customer__c, Customer_Owned_Unit__c, Subject, Transaction_Type__c, Event_Concern__c, Appointment_Concern__c FROM Event WHERE ID =: appointmentRecId AND Service_Order_Header__c != null];
        List<Service_Order_Header__c> soListToUpdate = new List<Service_Order_Header__c>();
        for(Event eventRec : eventList) {
            Service_Order_Header__c soRec = new Service_Order_Header__c(Id = eventRec.Service_Order_Header__c);
            soRec.Name__c = eventRec.Subject;
            soRec.SO_Concern__c = (eventRec.Event_Concern__c == null) ? eventRec.Appointment_Concern__c : '';
            
            if(String.isNotBlank(eventRec.Event_Concern__c)) {
                NotesService.populateConcernsOnSO(soRec, eventRec.Event_Concern__c);
            }
            soRec.Customer_Owned_Unit__c = eventRec.Customer_Owned_Unit__c;
            soListToUpdate.add(soRec);
        }
        
        if(soListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soListToUpdate;
        }
    }
    
    public static void populateSOKitConcernsOnAppointment(AppointmentWrapper appointmentObj, String soHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Kit_Header__c> soKitHeaderList = [SELECT Id, Kit_Header__c, Kit_Header__r.Concern__c FROM Service_Order_Kit_Header__c WHERE Service_Order_Header__c =: soHeaderId];
        for(Service_Order_Kit_Header__c soKitHeaderRec : soKitHeaderList) {
            if(soKitHeaderRec.Kit_Header__c != null && soKitHeaderRec.Kit_Header__r.Concern__c != null) {
                appointmentObj.SOKitConcern.addAll(soKitHeaderRec.Kit_Header__r.Concern__c.split('\n'));
            }
        }
    }
    
    public static List<TechnicianDetailWrapper> getTechnicianListWithAvailableHours(String appointmentDetailJSON) {
        AppointmentWrapper appointmentDetailObj = (AppointmentWrapper)System.JSON.deserialize(appointmentDetailJSON, AppointmentWrapper.class);
        DateTime selectedDate = HomeSearchFilterInterface.getDateFromString(appointmentDetailObj.StartDate);
        List<Technician__c> technicianList = SchedulerSOQLUtil.getTechnicianList(selectedDate);
        
        Date dateFromDateTime = Date.newinstance(selectedDate.year(), selectedDate.month(), selectedDate.day());
        String day = AccountSettingService.getDayNameFromDate(dateFromDateTime);
        
        if(AccessControl.ifObjectFieldIsAccessible('Shop_Settings__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Shop_Settings__c> shopSettingList = [Select Id, From_Time__c, To_Time__c from Shop_Settings__c where Day__c =: day AND Is_Working__c = true];
        
        List<TechnicianDetailWrapper> techObjList = new List<TechnicianDetailWrapper>();
        for(Technician__c techRec : technicianList) {
            techObjList.add(new TechnicianDetailWrapper(techRec, day, shopSettingList, selectedDate, appointmentDetailObj.EstimatedHours));
        }
        
        //system.assert(false, techObjList);
        return sortTechnicianList(techObjList, appointmentDetailObj.EstimatedHours, appointmentDetailObj.AppointmentDaySegment);
    }
    
    private static List<TechnicianDetailWrapper> sortTechnicianList(List<TechnicianDetailWrapper> techObjList, Decimal estimatedHours, String appointmentDaySegment) {
        List<TechnicianDetailWrapper> technicianListWithEnoughAvailableHoursInSameSegment = new List<TechnicianDetailWrapper>();
        List<TechnicianDetailWrapper> technicianListWithEnoughAvailableHoursInOppositeSegment = new List<TechnicianDetailWrapper>();
        List<TechnicianDetailWrapper> technicianListWithMostAvailableHours = new List<TechnicianDetailWrapper>();
        for(TechnicianDetailWrapper techObjRec: techObjList) {
            if(appointmentDaySegment == 'Morning') {
                if(techObjRec.AvailableHoursMorning >= EstimatedHours) {
                    techObjRec.HoursForSorting = techObjRec.AvailableHoursMorning;
                    technicianListWithEnoughAvailableHoursInSameSegment.add(techObjRec);
                } else if(techObjRec.AvailableHoursAfternoon >= EstimatedHours) {
                    techObjRec.HoursForSorting = techObjRec.AvailableHoursAfternoon;
                    technicianListWithEnoughAvailableHoursInOppositeSegment.add(techObjRec);
                } else {
                    techObjRec.HoursForSorting = (techObjRec.AvailableHoursMorning + techObjRec.AvailableHoursAfternoon);
                    technicianListWithMostAvailableHours.add(techObjRec);
                }
            } else if(appointmentDaySegment == 'Afternoon') {
                if(techObjRec.AvailableHoursAfternoon >= EstimatedHours) {
                    techObjRec.HoursForSorting = techObjRec.AvailableHoursAfternoon;
                    technicianListWithEnoughAvailableHoursInSameSegment.add(techObjRec);
                } else if(techObjRec.AvailableHoursMorning >= EstimatedHours) {
                    techObjRec.HoursForSorting = techObjRec.AvailableHoursMorning;
                    technicianListWithEnoughAvailableHoursInOppositeSegment.add(techObjRec);
                } else {
                    techObjRec.HoursForSorting = (techObjRec.AvailableHoursMorning + techObjRec.AvailableHoursAfternoon);
                    technicianListWithMostAvailableHours.add(techObjRec);
                }
            }
        }
        
        List<TechnicianDetailWrapper> sortedTechObjList = new List<TechnicianDetailWrapper>();
        
        technicianListWithEnoughAvailableHoursInSameSegment.sort();
        sortedTechObjList.addAll(technicianListWithEnoughAvailableHoursInSameSegment);
        
        technicianListWithEnoughAvailableHoursInOppositeSegment.sort();
        sortedTechObjList.addAll(technicianListWithEnoughAvailableHoursInOppositeSegment);
        
        technicianListWithMostAvailableHours.sort();
        sortedTechObjList.addAll(technicianListWithMostAvailableHours);
        return sortedTechObjList;
    }
   	
   	public static String getTimeSlotAndStateForTechnician(String timeSlotJson) {
   		TimeSlotWrapper timeSlotObj = (TimeSlotWrapper)System.JSON.deserialize(timeSlotJson, TimeSlotWrapper.class);
        List<ShopSettingWrapper> shopSettingData= AccountSettingService.getShopSettingDataForParticularDay(timeSlotObj.AppointmentDay);
        Time shopFromTime, shopEndTime, startTime, endTime ;
        
        for(Integer i = 0; i < shopSettingData.size(); i++) {
            if(shopSettingData[i].Day == timeSlotObj.AppointmentDay) {
				shopFromTime = DateTimeUtility.getTimeFromString(shopSettingData[i].FromTime);
				shopEndTime = DateTimeUtility.getTimeFromString(shopSettingData[i].ToTime);
				break;
            }
        }
        
        List<TimeSlotWrapper> timeSlotWrapper = new List<TimeSlotWrapper>();
        while(shopFromTime <= shopEndTime) {
        	timeSlotWrapper.add(new TimeSlotWrapper( shopFromTime, 'Available'));
        	shopFromTime = shopFromTime.addMinutes(15);
        }
        
   		DateTime selectedDate = HomeSearchFilterInterface.getDateFromString(timeSlotObj.AppointmentDate);
        Map<String, List<String>> queryParamMap = new Map<String, List<String>>{
                        'Technician__c' => new List<String>{'=', timeSlotObj.TechnicianId}
           };
        List<Event> appointmentList = SchedulerSOQLUtil.getAppoitmentList(queryParamMap, selectedDate); 
        
        Integer noOfMinutes = Integer.ValueOf((timeSlotObj.EstimatedHours * 60  * -1) + 15);
        Set<Time> notAvailableRecSet = new Set<Time>();
        Set<Time> pushedRecSet = new Set<Time>();
    	for(Event eventRec : appointmentList) {
    		startTime = Time.newInstance(eventRec.StartDateTime.hour(), eventRec.StartDateTime.minute(), eventRec.StartDateTime.second(), eventRec.StartDateTime.millisecond());
    		endTime = Time.newInstance(eventRec.EndDateTime.hour(), eventRec.EndDateTime.minute(), eventRec.EndDateTime.second(), eventRec.EndDateTime.millisecond());
    		while(startTime < endTime) {
    			notAvailableRecSet.add(startTime);
    			startTime = startTime.addMinutes(15);
    		}
    		startTime = Time.newInstance(eventRec.StartDateTime.hour(), eventRec.StartDateTime.minute(), eventRec.StartDateTime.second(), eventRec.StartDateTime.millisecond());
    		Time pushTimeInterval = startTime.addMinutes(noOfMinutes);
    		while(pushTimeInterval < startTime) {
    			pushedRecSet.add(pushTimeInterval);
    			pushTimeInterval = pushTimeInterval.addMinutes(15);
    		}
    	}
        for(TimeSlotWrapper timeslots : timeSlotWrapper) {
        	if(notAvailableRecSet.contains(timeslots.TimeSlot)) {
        		timeslots.availabiltyStatus = 'Not available';
        	} else if(!notAvailableRecSet.contains(timeslots.TimeSlot) && pushedRecSet.contains(timeslots.TimeSlot)) {
        		timeslots.availabiltyStatus = 'Push';
        	} else {
        		timeslots.availabiltyStatus = 'Available';
        	}
        	
        	Datetime timeSlotRecord = Datetime.newInstance(Date.newinstance(selectedDate.year(), selectedDate.month(), selectedDate.day()), timeslots.TimeSlot);
			timeslots.TimeSlotRec = timeSlotRecord.format('h:mm a');
			timeslots.TimeSlot = null;
        } 
        //system.assert(false, system.json.serialize(timeSlotWrapper,true));
        return system.json.serialize(timeSlotWrapper,true);
       
   	}
   	
   	public class TimeSlotWrapper{
   		public String AppointmentDate;
   		public String TechnicianId;
   		public String availabiltyStatus;
   		public Decimal EstimatedHours;
   		public Time TimeSlot;
   		public String TimeSlotRec;
   		public String AppointmentDay;
   		
   		public TimeSlotWrapper(Time timeSlot, String status) {
   			this.availabiltyStatus = status;
   			this.TimeSlot = timeSlot;
   		}
   	}
}