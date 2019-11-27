public without sharing class JobSchedulerService {
    
    public static List<TechnicianDetailWrapper> getTechnicianListForSpecificDay(String dateStr) {
        DateTime selectedDate = HomeSearchFilterInterface.getDateFromString(dateStr);
        List<Technician__c> technicianList = SchedulerSOQLUtil.getTechnicianList(selectedDate);
        
        Date dateFromDateTime = Date.newinstance(selectedDate.year(), selectedDate.month(), selectedDate.day());
        String day = AccountSettingService.getDayNameFromDate(dateFromDateTime);
        
        if(AccessControl.ifObjectFieldIsAccessible('Shop_Settings__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Shop_Settings__c> shopSettingList = [Select Id, From_Time__c, To_Time__c from Shop_Settings__c where Day__c =: day AND Is_Working__c = true];
        
        List<TechnicianDetailWrapper> techObjList = new List<TechnicianDetailWrapper>();
        for(Technician__c techRec : technicianList) {
            techObjList.add(new TechnicianDetailWrapper(techRec, day, shopSettingList, selectedDate));
        }
        return techObjList;
    }
    
    public static List<AppointmentWrapper> getUnassignedAppointmentForSpecificDay(String dateStr) {
        DateTime selectedDate = HomeSearchFilterInterface.getDateFromString(dateStr);
        Map<String, List<String>> queryParamMap = new Map<String, List<String>>{
                        'Technician__c' => new List<String>{'=', null}
           };
        List<Event> appointmentList = SchedulerSOQLUtil.getAppoitmentList(queryParamMap, selectedDate);
        
        List<AppointmentWrapper> appointmentObjList = new List<AppointmentWrapper>();
        for(Event appointmentRec : appointmentList) {
            AppointmentWrapper appointmentObj = new AppointmentWrapper(appointmentRec, true);
            if(String.isNotBlank(appointmentRec.Service_Order_Header__c)) {
                AppointmentService.populateSOKitConcernsOnAppointment(appointmentObj, appointmentRec.Service_Order_Header__c);
            }
            
            if(String.isNotBlank(appointmentRec.Event_Concern__c)) {
                NotesService.populateNotesOnAppointment(appointmentObj, appointmentRec.Event_Concern__c);
            }
            appointmentObjList.add(appointmentObj);
        }
        return appointmentObjList;
    }
    
    public static Map<String, List<AppointmentWrapper>> getAssignedAppointmentForSpecificDay(String dateStr, String techId) {
        DateTime selectedDate = HomeSearchFilterInterface.getDateFromString(dateStr);
        Map<String, List<String>> queryParamMap = new Map<String, List<String>>{
                        'CO_Header__c' => new List<String>{'<>', null}
        };
        if(techId != null) {
            queryParamMap.put('Technician__c', new List<String>{'=', techId});
        } else {
            queryParamMap.put('Technician__c', new List<String>{'<>', null});
        }
        List<Event> appointmentList = SchedulerSOQLUtil.getAppoitmentList(queryParamMap, selectedDate);
        
        Map<String, List<AppointmentWrapper>> techIdToAppointmentListMap = new Map<String, List<AppointmentWrapper>>();
        for(Event appointmentRec : appointmentList) {
            if(!techIdToAppointmentListMap.containsKey(appointmentRec.Technician__c)) {
                techIdToAppointmentListMap.put(appointmentRec.Technician__c, new List<AppointmentWrapper>());
            }
            
            AppointmentWrapper appointmentObj = new AppointmentWrapper(appointmentRec, true);
            if(String.isNotBlank(appointmentRec.Service_Order_Header__c)) {
                AppointmentService.populateSOKitConcernsOnAppointment(appointmentObj, appointmentRec.Service_Order_Header__c);
            }
            
            if(String.isNotBlank(appointmentRec.Event_Concern__c)) {
                NotesService.populateNotesOnAppointment(appointmentObj, appointmentRec.Event_Concern__c);
            }
            techIdToAppointmentListMap.get(appointmentRec.Technician__c).add(appointmentObj);
        }
        return techIdToAppointmentListMap;
    }
    
    public static void updateAppointment(String appointmentObjStr) {
        if(AccessControl.ifObjectFieldIsUpdateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<AppointmentWrapper> appObjList = (List<AppointmentWrapper>) system.JSON.deserialize(appointmentObjStr, List<AppointmentWrapper>.class);
        List<Event> eventListToUpdate = new List<Event>();
        for(AppointmentWrapper appObj : appObjList) {
            eventListToUpdate.add(updateAppointment(appObj));
        }
        if(eventListToUpdate.size() > 0) {
            update eventListToUpdate;
        }
    }
    
    private static Event updateAppointment(AppointmentWrapper appointmentObj) {
        Event eventRec = new Event(Id = appointmentObj.Id);
        eventRec.Technician__c = appointmentObj.TechnicianId;
        if(String.isNotBlank(appointmentObj.StartDate) && String.isNotBlank(appointmentObj.StartTime)) {
            eventRec.StartDateTime = DateTimeUtility.getConvertedDateTime(appointmentObj.StartDate, appointmentObj.StartTime);
        }
        if(String.isNotBlank(appointmentObj.EndTime)) {
            eventRec.EndDateTime = DateTimeUtility.getConvertedDateTime(appointmentObj.StartDate, appointmentObj.EndTime);
        }
        if(String.isNotBlank(appointmentObj.StartTime)) {
            if(appointmentObj.StartTime.toLowerCase().contains('am')) {
                eventRec.Appointment_Day_Segment__c = 'Morning'; 
            } else if(appointmentObj.StartTime.toLowerCase().contains('pm')){
                eventRec.Appointment_Day_Segment__c = 'Afternoon';
            }
        }
        return eventRec;
    }
    
    public static String createCOWithServiceJob(String appointmentObjStr) {
        if(AccessControl.ifObjectFieldIsCreateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        AppointmentWrapper appointmentObj = (AppointmentWrapper) system.JSON.deserialize(appointmentObjStr, AppointmentWrapper.class);
        String coHeaderId;
        if(appointmentObj.COId == null) {
            CO_Header__c coHeaderRec = setCOHeaderFields(appointmentObj.CustomerId, 'Customer', null);
            insert coHeaderRec;
            coHeaderId = coHeaderRec.Id;
            ServiceJobService.createServiceJob(coHeaderRec.Id);
            // Set Appointment related to CO Header
            Event eventRec = new Event(Id = appointmentObj.Id, CO_Header__c = coHeaderRec.Id);
            
            List<Service_Order_Header__c> soHeaderList = [Select Id from Service_Order_Header__c where CO_Header__c =: coHeaderRec.Id];
            if(soHeaderList.size() > 0) {
                soHeaderList[0].Customer_Owned_Unit__c = appointmentObj.COUId;
                soHeaderList[0].SO_Concern__c = BPUtility.convertListIntoString(appointmentObj.Concern);
                soHeaderList[0].Transaction_Type__c = appointmentObj.TransactionTypeId;
                soHeaderList[0].Name__c = appointmentObj.Title;
                List<Transaction_Type__c> ttList = [SELECT Type__c FROM Transaction_Type__c WHERE Id =: appointmentObj.TransactionTypeId];
                if(ttList.size() > 0 && ttList[0].Type__c == 'Third-Party') {
                    soHeaderList[0].Claim_Status__c = 'Unsubmitted';
                }
                update soHeaderList[0];
                
                // Set Appointment related to SO Header
                eventRec.Service_Order_Header__c = soHeaderList[0].Id;
            }
            
            update eventRec;
            
        } else {
            coHeaderId = appointmentObj.COId;
        }
        return coHeaderId;
    }
    
    private static CO_Header__c setCOHeaderFields(String customerId, String coType, String sellingGroup) {
        CO_Header__c coHeaderRec = new CO_Header__c();
        coHeaderRec.Order_status__c = 'Open';
        coHeaderRec.Owner__c = UserInfo.getUserId();
        coHeaderRec.Selling_Group__c = sellingGroup;
        coHeaderRec.CO_Type__c = coType;
        coHeaderRec.Customer__c = customerId;
        coHeaderRec.Hide_Merchandise_Section__c = true;
        return coHeaderRec;
    }
}