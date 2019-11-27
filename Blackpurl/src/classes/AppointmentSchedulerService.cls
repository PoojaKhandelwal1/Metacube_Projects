/** 
* Author: Nidhi Sharma <nidhi.sharma@metacube.com>
* Since: May 17, 2018 
* Name: AppointmentSchedulerService
* Description: Apex class which contains all service methods related to Appointment Scheduling
**/
public with sharing class AppointmentSchedulerService {
   
    public static AppointmentSchedulerWrapper getAppointmentSchedulerDataForDateRange(String fromDateStr, String toDateStr) {
        if(AccessControl.ifObjectFieldIsAccessible('Shop_Settings__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        DateTime fromDate = HomeSearchFilterInterface.getDateFromString(fromDateStr);
        DateTime toDate = HomeSearchFilterInterface.getDateFromString(toDateStr);
        
        //DateTime fromDate = String.isNotBlank(fromDateStr) ? Date.parse(fromDateStr) : system.today();
        //DateTime toDate = String.isNotBlank(toDateStr) ? Date.parse(toDateStr) : fromDate.addDays(7);
        
        List<ShopSettingWrapper> shopSettingData = AccountSettingService.getShopSettingData();
        
        Map<String, Map<String, String>> weedDayToAMAndPMWorkingHoursStrMap = new Map<String, Map<String, String>>();
        for(Integer i = 0; i < shopSettingData.size(); i++) {
        	if(shopSettingData[i].IsWorking) {
    			weedDayToAMAndPMWorkingHoursStrMap.put(shopSettingData[i].Day, new Map<String, String>{'From' => shopSettingData[i].FromTime, 'To' => shopSettingData[i].ToTime});
        	}
        }
        
        List<Technician__c> technicianRecList = SOQLUtil.getTechniciansWithLeaveWithinTimePeriod(null,fromDate, toDate); // Re-factor this method to a separate SOQL-DAO, add start and end date params
        
        Map<String, List<Technician__c>> weekDayToWorkingTechnicianListMap = new Map<String, List<Technician__c>>();
        Map<String, Decimal> weekDayToLeaveHoursMapMorning = new Map<String, Decimal>();
        Map<String, Decimal> weekDayToLeaveHoursMapAfternoon = new Map<String, Decimal>();
        
        for(Technician__c techRec : technicianRecList) {
            if(String.isNotBlank(techRec.Working_Days__c)) {
                Set<String> technicianWorkingDaySet = new Set<String>(techRec.Working_Days__c.split(';'));
                for(String workingDay : technicianWorkingDaySet) {
                    if(!weekDayToWorkingTechnicianListMap.containsKey(workingDay)) {
                        weekDayToWorkingTechnicianListMap.put(workingDay, new List<Technician__c>());
                    }
                    weekDayToWorkingTechnicianListMap.get(workingDay).add(techRec);
                }
                for(Leave__c leaveRec : techRec.Leaves__r) {
                    Map<String, List<DateTime>> leaveDaysToDateMap = DateTimeUtility.getDaysDateMapForDateRange(leaveRec.From__c, leaveRec.To__c);
                    Map<String, List<DateTime>> leaveDaysToDateMapWithinGivenPeriod = DateTimeUtility.removeDateNotWithinRange(leaveDaysToDateMap, fromDate, toDate);
                    
                    Map<String, List<DateTime>> leaveDaysToWorkingDateMapWithinGivenPeriod = leaveDaysToDateMapWithinGivenPeriod;
                    
                    for(String leaveDay : leaveDaysToDateMapWithinGivenPeriod.keySet()) {
                    	if(!technicianWorkingDaySet.contains(leaveDay)) {
                    		leaveDaysToWorkingDateMapWithinGivenPeriod.remove(leaveDay);
                    	}
                    }
                    
                    leaveDaysToDateMapWithinGivenPeriod = leaveDaysToWorkingDateMapWithinGivenPeriod;
                    for(String day : leaveDaysToDateMapWithinGivenPeriod.keySet()) {
                        Decimal leaveDurationHoursMorning = 0;
                        Decimal leaveDurationHoursAfternoon = 0;
                        if(weedDayToAMAndPMWorkingHoursStrMap.containsKey(day)) {
                        	Time shopFromTime = DateTimeUtility.getTimeFromString(weedDayToAMAndPMWorkingHoursStrMap.get(day).get('From'));
                    		Time shopToTime = DateTimeUtility.getTimeFromString(weedDayToAMAndPMWorkingHoursStrMap.get(day).get('To'));
                        	
                    		Time leaveFromTime = DateTimeUtility.getTimeFromString(leaveRec.From__c.format('h:mma'));
                    		Time leaveToTime = DateTimeUtility.getTimeFromString(leaveRec.To__c.format('h:mma'));
                        	
                        	if(shopFromTime >= leaveToTime || shopToTime <= leaveFromTime) {
                        		continue;
                        	}
                        	String fromTimeStr = (leaveFromTime > shopFromTime) ? leaveRec.From__c.format('h:mma') : weedDayToAMAndPMWorkingHoursStrMap.get(day).get('From');
                    		String toTimeStr = (leaveToTime < shopToTime) ? leaveRec.To__c.format('h:mma') : weedDayToAMAndPMWorkingHoursStrMap.get(day).get('To');
                        	
                            leaveDurationHoursMorning = DateTimeUtility.getTimeBySegment('AM', fromTimeStr, toTimeStr);
                    		leaveDurationHoursAfternoon = DateTimeUtility.getTimeBySegment('PM', fromTimeStr, toTimeStr);
                        }                    	
                        if(!weekDayToLeaveHoursMapMorning.containsKey(day)){
                            weekDayToLeaveHoursMapMorning.put(day, 0.0 );
                        }                        
                        weekDayToLeaveHoursMapMorning.put(day,weekDayToLeaveHoursMapMorning.get(day) + leaveDurationHoursMorning*(leaveDaysToDateMapWithinGivenPeriod.get(day).size()));
                        if(!weekDayToLeaveHoursMapAfternoon.containsKey(day)){
                            weekDayToLeaveHoursMapAfternoon.put(day, 0.0);
                        }
                        weekDayToLeaveHoursMapAfternoon.put(day,weekDayToLeaveHoursMapAfternoon.get(day) + leaveDurationHoursAfternoon*(leaveDaysToDateMapWithinGivenPeriod.get(day).size()));
                    }
                }
            }
        }
        
        //Get Appointment
        List<Event> appointmentList = SchedulerSOQLUtil.getAppointmentWithinPeriod(fromDate, toDate);
        Map<String, Decimal> weekDayToAMAppointmentHoursMap = new Map<String, Decimal>();
        Map<String, Integer> weekDayToAMTotalAppointmentMap = new Map<String, Integer>();
        Map<String, Decimal> weekDayToPMAppointmentHoursMap = new Map<String, Decimal>();
        Map<String, Integer> weekDayToPMTotalAppointmentMap = new Map<String, Integer>();
        Time pmSegmentStartTime = Time.newInstance(12,0,0,0);
        for(Event appointmentObj : appointmentList) {
            appointmentObj.Estimated_Hours__c = (appointmentObj.Estimated_Hours__c != null) ? appointmentObj.Estimated_Hours__c : 0;
            //AM Segment
            if(appointmentObj.Appointment_Day_Segment__c == 'Morning') {
                if(!weekDayToAMTotalAppointmentMap.containsKey(appointmentObj.StartDateTime.format('EEEE'))) {
                    weekDayToAMTotalAppointmentMap.put(appointmentObj.StartDateTime.format('EEEE'), 0);
                }
                weekDayToAMTotalAppointmentMap.put(appointmentObj.StartDateTime.format('EEEE'), weekDayToAMTotalAppointmentMap.get(appointmentObj.StartDateTime.format('EEEE')) + 1);
                if(!weekDayToAMAppointmentHoursMap.containsKey(appointmentObj.StartDateTime.format('EEEE'))) {
                    weekDayToAMAppointmentHoursMap.put(appointmentObj.StartDateTime.format('EEEE'), 0.00);
                }
                weekDayToAMAppointmentHoursMap.put(appointmentObj.StartDateTime.format('EEEE'), 
                    weekDayToAMAppointmentHoursMap.get(appointmentObj.StartDateTime.format('EEEE')) + appointmentObj.Estimated_Hours__c);
            } else {
                //PM Segment
                if(!weekDayToPMTotalAppointmentMap.containsKey(appointmentObj.StartDateTime.format('EEEE'))) {
                    weekDayToPMTotalAppointmentMap.put(appointmentObj.StartDateTime.format('EEEE'), 0);
                }
                weekDayToPMTotalAppointmentMap.put(appointmentObj.StartDateTime.format('EEEE'), weekDayToPMTotalAppointmentMap.get(appointmentObj.StartDateTime.format('EEEE')) + 1);
                if(!weekDayToPMAppointmentHoursMap.containsKey(appointmentObj.StartDateTime.format('EEEE'))) {
                    weekDayToPMAppointmentHoursMap.put(appointmentObj.StartDateTime.format('EEEE'), 0.00);
                }
                weekDayToPMAppointmentHoursMap.put(appointmentObj.StartDateTime.format('EEEE'), 
                    weekDayToPMAppointmentHoursMap.get(appointmentObj.StartDateTime.format('EEEE')) + appointmentObj.Estimated_Hours__c);
            }
        }
        
        List<AppointmentDayWrapper> appointmentDayDataList = new List<AppointmentDayWrapper>();
        Decimal totalWorkingHours = 0.00;
        Decimal bookedAppointmentHours = 0.00;
        DateTime currentDate = fromDate; 
        for(Integer i = 0; i < shopSettingData.size(); i++) {
            AppointmentDayWrapper appointmentDayDataObj = new AppointmentDayWrapper(i, shopSettingData[i].Day, currentDate, shopSettingData[i].IsWorking);
            appointmentDayDataObj.DaySegments = new List<AppointmentDayWrapper.DaySegmentWrapper>();
            
            Integer numberOfTechnicians = (weekDayToWorkingTechnicianListMap.containsKey(shopSettingData[i].Day)) ? weekDayToWorkingTechnicianListMap.get(shopSettingData[i].Day).size() : 0;
            
            //AM Segment
            Decimal morningShopHours = shopSettingData[i].IsWorking ? DateTimeUtility.getTimeBySegment('AM', shopSettingData[i].FromTime, shopSettingData[i].ToTime) : 0;
            Decimal morningLeaveHours = (shopSettingData[i].IsWorking && weekDayToLeaveHoursMapMorning.containsKey(shopSettingData[i].Day)) ? weekDayToLeaveHoursMapMorning.get(shopSettingData[i].Day) : 0;
            
            Decimal morningTotalWorkingHours = (morningShopHours * numberOfTechnicians) - morningLeaveHours;
            Decimal morningBookedAppointmentHours = weekDayToAMAppointmentHoursMap.containsKey(shopSettingData[i].Day) ? weekDayToAMAppointmentHoursMap.get(shopSettingData[i].Day) : 0;
            Integer morningTotalAppointments = weekDayToAMTotalAppointmentMap.containsKey(shopSettingData[i].Day) ? weekDayToAMTotalAppointmentMap.get(shopSettingData[i].Day) : 0;
            
            appointmentDayDataObj.DaySegments.add(new AppointmentDayWrapper.DaySegmentWrapper(morningTotalWorkingHours, morningBookedAppointmentHours, morningTotalAppointments));
            
            //PM Segment
            Decimal eveningShopHours = shopSettingData[i].IsWorking ? DateTimeUtility.getTimeBySegment('PM', shopSettingData[i].FromTime, shopSettingData[i].ToTime) : 0;
            Decimal eveningLeaveHours = (shopSettingData[i].IsWorking && weekDayToLeaveHoursMapAfternoon.containsKey(shopSettingData[i].Day)) ? weekDayToLeaveHoursMapAfternoon.get(shopSettingData[i].Day) : 0;
            
            Decimal eveningTotalWorkingHours = (eveningShopHours * numberOfTechnicians) - eveningLeaveHours;
            Decimal eveningBookedAppointmentHours = weekDayToPMAppointmentHoursMap.containsKey(shopSettingData[i].Day) ? weekDayToPMAppointmentHoursMap.get(shopSettingData[i].Day) : 0;
            Integer eveningTotalAppointments = weekDayToPMTotalAppointmentMap.containsKey(shopSettingData[i].Day) ? weekDayToPMTotalAppointmentMap.get(shopSettingData[i].Day) : 0;
            //system.assert(shopSettingData[i].Day != 'Thursday' , eveningShopHours + '  '+numberOfTechnicians+'  '+eveningLeaveHours);
            appointmentDayDataObj.DaySegments.add(new AppointmentDayWrapper.DaySegmentWrapper(eveningTotalWorkingHours, eveningBookedAppointmentHours, eveningTotalAppointments));
            
            appointmentDayDataList.add(appointmentDayDataObj);
            
            totalWorkingHours += (morningTotalWorkingHours + eveningTotalWorkingHours);
            bookedAppointmentHours += (morningBookedAppointmentHours + eveningBookedAppointmentHours);
            
            currentDate = currentDate.addDays(1);
        }
        AppointmentSchedulerWrapper appointmentSchedulerObj = new AppointmentSchedulerWrapper(fromDate, toDate, totalWorkingHours, bookedAppointmentHours, appointmentDayDataList);
        return appointmentSchedulerObj;
    }
}