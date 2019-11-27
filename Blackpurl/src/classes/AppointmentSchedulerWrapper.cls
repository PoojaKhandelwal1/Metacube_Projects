/**
* @author Nidhi Sharma <yash.sharma@metacube.com>
* @Description Bean object for Schedule Appointment
*/
public with sharing class AppointmentSchedulerWrapper {
    
    public String DateFrom;
    public String DateTo;
    public Decimal TotalWorkingHours;
    public Decimal BookedHours;
    public List<AppointmentDayWrapper> WeekDataList;
    
    public AppointmentSchedulerWrapper(DateTime fromdate, DateTime toDate, Decimal totalWorkingHours, Decimal bookedHours, List<AppointmentDayWrapper> weekDaysDataList) {
        if(fromdate != null){
    		this.DateFrom = BPUtility.getFormatedDateTime(datetime.newInstance(fromdate.year(), fromdate.month(), fromdate.day()));
    	}
    	if(toDate != null){
    		this.DateTo = BPUtility.getFormatedDateTime(datetime.newInstance(toDate.year(), toDate.month(), toDate.day()));
    	}
        this.TotalWorkingHours = totalWorkingHours;
        this.BookedHours = bookedHours;
        this.WeekDataList = weekDaysDataList;
    }
}