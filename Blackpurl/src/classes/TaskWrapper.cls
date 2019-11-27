/**
 * Author: Hitesh Gupta
 * Since: Oct 28, 2017 
 * Name: TaskWrapper
 * Description: Used to handle all JSON related work related to Task Object
**/
public with sharing class TaskWrapper implements Comparable {
    
    public String Id;
    public String Name;
    public Boolean IsClockedOn;
    public List<JobClockingWrapper.TechnicianInfo> TechnicianList;
    public String CurrentlyClocked;
	public Integer CurrentlyClockedDays;
	public Integer CurrentlyClockedHours;
	public Integer CurrentlyClockedMinutes;
	public String TimeSpent;
	public Integer TimeSpentDays;
	public Integer TimeSpentHours;
	public Integer TimeSpentMinutes;
    
    public TaskWrapper(Task__c taskObj, String technicianId){
    	this.Id = taskObj.Id;
    	this.Name = taskObj.Name__c;
    	this.IsClockedOn = false;
    	
    	this.TimeSpentDays = 0;
		this.TimeSpentHours = 0;
		this.TimeSpentMinutes = 0;
		
    	for(Hours_Logged__c hoursLogged: taskObj.Hours_Logged__r) {
    		if(technicianId != null && hoursLogged.Technician__c == technicianId 
    			&& hoursLogged.Start_Date_Time__c != null && hoursLogged.End_Date_Time__c == null){
    			this.IsClockedOn = true;
    			break;
    		}
    	}
    	
    	Map<Id, List<Hours_Logged__c>> technicianIdtoHoursLoggedMap = new Map<Id, List<Hours_Logged__c>>();
		for(Hours_Logged__c hoursLogged: taskObj.Hours_Logged__r) {
			if(technicianId != null) {
				this.TimeSpentDays += hoursLogged.Time_Spent_d__c != null ? hoursLogged.Time_Spent_d__c.intValue() : 0;
				this.TimeSpentHours += hoursLogged.Time_Spent_h__c!= null ? hoursLogged.Time_Spent_h__c.intValue() : 0;
				this.TimeSpentMinutes += hoursLogged.Time_Spent_m__c!= null ? hoursLogged.Time_Spent_m__c.intValue() : 0;
			}
			
			if(hoursLogged.Technician__c != null) {
				if(!technicianIdtoHoursLoggedMap.containsKey(hoursLogged.Technician__c)) {
					List<Hours_Logged__c> hoursLoggedList = new List<Hours_Logged__c>();
					hoursLoggedList.add(hoursLogged);
					technicianIdtoHoursLoggedMap.put(hoursLogged.Technician__c, hoursLoggedList);
				} else {
					technicianIdtoHoursLoggedMap.get(hoursLogged.Technician__c).add(hoursLogged);
				}
			}
		}
		//system.assert(false, technicianIdtoHoursLoggedMap);
		
		Long TotalTimeSpentMinutes = this.TimeSpentMinutes + (this.TimeSpentHours*60) + (this.TimeSpentDays*24*60);
		Long spentHours = TotalTimeSpentMinutes / 60;
		Long spentDdays = spentHours / 24;
		//this.TimeSpentDays = spentDdays.intValue();
		//this.TimeSpentHours = (math.mod(spentHours, 24)).intValue();
		this.TimeSpentDays = 0;
		this.TimeSpentHours = spentHours.intValue();
		this.TimeSpentMinutes = (math.mod(TotalTimeSpentMinutes, 60)).intValue();
		
		this.TechnicianList = new List<JobClockingWrapper.TechnicianInfo>();
		for(Id techId: technicianIdtoHoursLoggedMap.keySet()) {
			for(Hours_Logged__c hrsLogged: technicianIdtoHoursLoggedMap.get(techId)) {
				if(hrsLogged.Start_Date_Time__c != null && hrsLogged.End_Date_Time__c == null) {
					if(hrsLogged.Technician__r.Active__c && !hrsLogged.Is_Removed__c) {
						this.TechnicianList.add(new JobClockingWrapper.TechnicianInfo(technicianIdtoHoursLoggedMap.get(techId)));
					}
					break;
				}
			}
		}
		
		this.CurrentlyClockedDays = 0;
		this.CurrentlyClockedHours = 0;
		this.CurrentlyClockedMinutes = 0;
		
		DateTime currentDateTime = System.now();
		for(JobClockingWrapper.TechnicianInfo tech: this.TechnicianList) {
			if(((technicianId != null && tech.TechnicianId == technicianId)) && tech.IsClocked) {
				DateTime startDateTime = tech.StartTime;
				
				Long dt1Long = startDateTime.getTime();
				Long dt2Long = currentDateTime.getTime();
				Long currentMilliseconds = dt2Long - dt1Long;
				Long currentSeconds = currentMilliseconds / 1000;
				Long currentMinutes = (currentSeconds / 60);
				Long currentHours = currentMinutes / 60;
				Long currentDays = currentHours / 24;
				this.CurrentlyClockedHours = currentHours.intValue();
				this.CurrentlyClockedMinutes = (math.mod(currentMinutes, 60)).intValue();
				break;
			}
		}
		this.CurrentlyClocked = (String.valueOf(this.CurrentlyClockedHours).length() < 2 ? '0' + String.valueOf(this.CurrentlyClockedHours) + 'h' : String.valueOf(this.CurrentlyClockedHours) + 'h') + (String.valueOf(this.CurrentlyClockedMinutes).length() < 2 ? '0' + String.valueOf(this.CurrentlyClockedMinutes) + 'min' : String.valueOf(this.CurrentlyClockedMinutes) + 'min');
		
		this.TimeSpentDays += this.CurrentlyClockedDays;
		this.TimeSpentHours += this.CurrentlyClockedHours;
		this.TimeSpentMinutes += this.CurrentlyClockedMinutes;
		
		Long TotalPlusCurrentMinutes = this.TimeSpentMinutes + (this.TimeSpentHours*60) + (this.TimeSpentDays*24*60);
		
		Long spentHoursTotalPlusCurrent = TotalPlusCurrentMinutes / 60;
		Long spentDdaysTotalPlusCurrent = spentHoursTotalPlusCurrent / 24;
		this.TimeSpentHours = spentHoursTotalPlusCurrent.intValue();
		this.TimeSpentMinutes = (math.mod(TotalPlusCurrentMinutes, 60)).intValue();
		
		this.TimeSpent = (String.valueOf(this.TimeSpentHours).length() < 2 ? '0' + String.valueOf(this.TimeSpentHours) + 'h' : String.valueOf(this.TimeSpentHours) + 'h') + (String.valueOf(this.TimeSpentMinutes).length() < 2 ? '0' + String.valueOf(this.TimeSpentMinutes) + 'min' : String.valueOf(this.TimeSpentMinutes) + 'min');
    }
    
    
    public Integer compareTo(Object compareToObj) {
    	TaskWrapper compareToWrapperObj = (TaskWrapper)compareToObj;
    	if (IsClockedOn == compareToWrapperObj.IsClockedOn) return 0;
        if (IsClockedOn == true && compareToWrapperObj.IsClockedOn == false) return -1;
        return 1; 
    }
    
    
    
    public class OtherTaskWrapper {
    	public String Id;
    	public String TechId;
    	public String TaskId;
    	public String TaskName;
    	public String TechnicianFirstName;
    	public String TechnicianLastName;
    	public String StartDate;
    	public String EndDate;
    	public String StartTime;
    	public String EndTime;
    	public String TimeDifference;
    	
    	public OtherTaskWrapper(Hours_Logged__c hoursLoggedRec){
    		this.Id = hoursLoggedRec.Id;
    		this.TechId = hoursLoggedRec.Technician__c;
    		this.TaskId = hoursLoggedRec.Task__c;
    		this.TaskName = hoursLoggedRec.Task__r.Name__c;
    		this.TechnicianFirstName = hoursLoggedRec.Technician__r.First_Name__c;
    		this.TechnicianLastName = hoursLoggedRec.Technician__r.Last_Name__c;
    		this.StartDate = hoursLoggedRec.Start_Date_Time__c != null ? BPUtility.getFormatedDateTime(hoursLoggedRec.Start_Date_Time__c) : '';
    		this.EndDate = hoursLoggedRec.End_Date_Time__c != null ? BPUtility.getFormatedDateTime(hoursLoggedRec.End_Date_Time__c) : '';
    		
    		this.StartTime = hoursLoggedRec.Start_Date_Time__c != null ? String.valueOf(hoursLoggedRec.Start_Date_Time__c.format('dd/MM/yyyy-h:mm a')).Split('-')[1] : '';
    		this.EndTime = hoursLoggedRec.End_Date_Time__c != null ? String.valueOf(hoursLoggedRec.End_Date_Time__c.format('dd/MM/yyyy-h:mm a')).Split('-')[1] : '';
    		
    		
    		this.TimeDifference = (hoursLoggedRec.Time_Spent_h__c != null ? (Integer.valueOf(hoursLoggedRec.Time_Spent_h__c) < 10 ? ('0' + hoursLoggedRec.Time_Spent_h__c) : 
    																		(''+hoursLoggedRec.Time_Spent_h__c)) : '00') + 'h' +
    								(hoursLoggedRec.Time_Spent_m__c != null ? (Integer.valueOf(hoursLoggedRec.Time_Spent_m__c) < 10 ? '0' + hoursLoggedRec.Time_Spent_m__c : 
    																		(''+hoursLoggedRec.Time_Spent_m__c)) : '00')+ 'm';
    	}
    }
}