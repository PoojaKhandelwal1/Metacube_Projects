/** 
* Author: Nidhi Sharma <nidhi.sharma@metacube.com>
* Since: May 17, 2018 
* Name: TechnicianSchedulingCtrl
* Description: Apex class which contains all remoted methods related to Technician Scheduling
**/
global without sharing class SchedulerCtrl {
    global SchedulerCtrl(NewHomePageCtrl controller){} 
    public SchedulerCtrl() {}
    
    @RemoteAction
    global static String getShopSettingData() {
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(AccountSettingService.getShopSettingData(), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getAppointmentSchedulerDataForDateRange(String fromDateStr, String toDateStr) {
    	fromDateStr = BPUtility.getDecodedString(fromDateStr);
    	toDateStr = BPUtility.getDecodedString(toDateStr);
    	try {
    		AppointmentSchedulerWrapper appointmentSchedulerObj = AppointmentSchedulerService.getAppointmentSchedulerDataForDateRange(fromDateStr, toDateStr);
	        return BPUtility.getEncodedString(system.JSON.serialize(appointmentSchedulerObj, true));
    	} catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getTechnicianListForSpecificDay(String dateStr) {
        dateStr = BPUtility.getDecodedString(dateStr);
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(JobSchedulerService.getTechnicianListForSpecificDay(dateStr), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getUnassignedAppointmentForSpecificDay(String dateStr) {
        dateStr = BPUtility.getDecodedString(dateStr);
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(JobSchedulerService.getUnassignedAppointmentForSpecificDay(dateStr), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getAssignedAppointmentForSpecificDay(String dateStr) {
        dateStr = BPUtility.getDecodedString(dateStr);
        try {
            Map<String, List<AppointmentWrapper>> techIdToAppointmentListMap = JobSchedulerService.getAssignedAppointmentForSpecificDay(dateStr, null);
            return BPUtility.getEncodedString(system.JSON.serialize(techIdToAppointmentListMap, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static void updateAppointment(String appointmentObjStr) {
        appointmentObjStr = BPUtility.getDecodedString(appointmentObjStr);
        try {
            JobSchedulerService.updateAppointment(appointmentObjStr);
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String createCOForAppointment(String appointmentObjStr) {
        appointmentObjStr = BPUtility.getDecodedString(appointmentObjStr);
        try {
            return BPUtility.getEncodedString(JobSchedulerService.createCOWithServiceJob(appointmentObjStr));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}