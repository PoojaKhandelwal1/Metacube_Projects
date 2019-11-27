/** 
* Author: Rajat Jain <rajat.jain@metacube.com>
* Since: May 17, 2018 
* Name: AppointmentWrapper
* Description: Apex class which contains all Appointment Data Wrapper
**/
public with sharing class AppointmentWrapper {
    public String Id;
    public String CustomerId;
    public String COUId;
    public List<String> Concern;
    public List<String> SOKitConcern;
    public Decimal EstimatedHours;
    public String TransactionTypeLabel;
    public String TransactionTypeId;
    public String TransactionType;
    public String Title;
    
    public Boolean isConflictExists;
    
    public String StartDate;
    public String EndDate;
    public String StartTime;
    public String EndTime;
    public String FormattedStartDate;
    
    public String CustomerName;
    public String COId;
    public String CONumber;
    public String UnitFormattedName;
    public String AppointmentDaySegment;
    public String TechnicianId;
    public String TechnicianName;
    public String SOHeaderId;
    
    public AppointmentWrapper(Event scheduleEventRec) {
        populateDefaultFields(scheduleEventRec);
    }
    
    public AppointmentWrapper(Event eventRec, Boolean needUnitDetail) {
        populateDefaultFields(eventRec);
        this.TechnicianId = (eventRec.Technician__c != null) ? eventRec.Technician__c : null;
        this.TechnicianName = (eventRec.Technician__c != null) ? eventRec.Technician__r.Technician_Name__c : null;
        this.CustomerName = (eventRec.Customer__r.Name != null) ? eventRec.Customer__r.Name : null;
        this.UnitFormattedName = eventRec.Customer_Owned_Unit__r.Formatted_Name__c;
        this.AppointmentDaySegment = eventRec.Appointment_Day_Segment__c;
        this.CONumber = (eventRec.CO_Header__r.Name != null) ? eventRec.CO_Header__r.Name : null;
        this.COId = (eventRec.CO_Header__c != null) ? eventRec.CO_Header__c : null;
        this.StartDate = (eventRec.StartDateTime != null) ? BPUtility.getFormatedDateTime(eventRec.StartDateTime) : null;
        this.SOHeaderId = (eventRec.Service_Order_Header__c != null) ? eventRec.Service_Order_Header__c : null;
        this.StartTime = (eventRec.StartDateTime != null) ? eventRec.StartDateTime.format('h:mma') : null;
        this.EndTime = (eventRec.EndDateTime != null) ? eventRec.EndDateTime.format('h:mma') : null;
        this.FormattedStartDate = null;
        if(eventRec.StartDateTime != null) {
            this.FormattedStartDate = eventRec.StartDateTime.format('MMMM dd, yyyy');
        }
    }
    
    private void populateDefaultFields(Event scheduleEventRec) {
        this.Id = scheduleEventRec.Id;
        this.CustomerId = scheduleEventRec.Customer__c;
        this.Concern = (scheduleEventRec.Event_Concern__c == null && scheduleEventRec.Appointment_Concern__c != null) ? scheduleEventRec.Appointment_Concern__c.split('\n') : new List<String>();
        this.SOKitConcern = new List<String>();
        this.COUId = scheduleEventRec.Customer_Owned_Unit__c;
        this.EstimatedHours= scheduleEventRec.Estimated_Hours__c;
        this.TransactionTypeLabel = scheduleEventRec.Transaction_Type__r.Code_Label__c;
        this.TransactionTypeId = scheduleEventRec.Transaction_Type__c;
        this.TransactionType = scheduleEventRec.Transaction_Type__r.Type__c;
        this.Title = scheduleEventRec.Subject;
    }
    
    public static List<String> getAppointmentFieldsList() {
       return new List<String>{'Technician__c', 
       							'Technician__r.Technician_Name__c',
                                'Subject', 
                                'Appointment_Day_Segment__c',
                                'Transaction_Type__c',
                                'Transaction_Type__r.Code_Label__c',
                                'Transaction_Type__r.Type__c',
                                'Estimated_Hours__c', 
                                'StartDateTime',
                                'EndDateTime', 
                                'Customer_Owned_Unit__c',
                                'Customer__c',
                                'CO_Header__c',
                                'CO_Header__r.Name',
                                'Appointment_Concern__c',
                                'Customer__r.Name',
                                'Customer_Owned_Unit__r.Formatted_Name__c',
                                'Service_Order_Header__c',
                                'Event_Concern__c'};
    }
}