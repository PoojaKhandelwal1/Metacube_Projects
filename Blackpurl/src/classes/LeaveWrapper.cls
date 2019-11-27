public without sharing class LeaveWrapper {
	public String Id;
	public String Type;
	public String TechnicianId;
	public String FromDate;
	public String FromTime;
    public String ToDate;
    public String ToTime;
	public static String SchedulingDateFormat { get{return Constants.localeToDateTimeFmtMap.containsKey(UserInfo.getLocale()) ? Constants.localeToDateTimeFmtMap.get(UserInfo.getLocale()): Constants.localeToDateTimeFmtMap.get('en_AU'); } private set;}
	
	public LeaveWrapper(Leave__c leaveRec) {
		Id = leaveRec.Id;
		Type = leaveRec.Name;
		TechnicianId = leaveRec.Technician__c;
        if(leaveRec.From__c != null) {
            this.FromDate = getFormattedDate(leaveRec.From__c);
            this.FromTime = getFormattedTime(leaveRec.From__c); 
        }
        if(leaveRec.To__c != null) {
            this.ToDate = getFormattedDate(leaveRec.To__c);
            this.ToTime = getFormattedTime(leaveRec.To__c); 
        }
	}
	
	private static String getFormattedDate(DateTime dt) {
	    List<String> datetimeValue = String.valueOf(dt.format(SchedulingDateFormat + '-h:mma')).split('-'); 
        return datetimeValue[0];
	}
	
	public static String getFormattedTime(DateTime dt) {
	    List<String> datetimeValue = String.valueOf(dt.format(SchedulingDateFormat + '-h:mma')).split('-'); 
        String formattedTime = datetimeValue[1]; 
        
        List<String> ActualTimeHourAndMin = formattedTime.Split(':');
        String ActualTimeHour = ActualTimeHourAndMin[0];
        String ActualTimeMin = ActualTimeHourAndMin[1].substring(0, ActualTimeHourAndMin[1].length() - 2);
        String ActualTimePeriod = ActualTimeHourAndMin[1].substring(ActualTimeHourAndMin[1].length() - 2, ActualTimeHourAndMin[1].length());
        
        if(integer.valueof(ActualTimeMin) > 00 && integer.valueof(ActualTimeMin) <= 14 )    {
            formattedTime = ActualTimeHour + ':' + '00' + ActualTimePeriod;
        } else if(integer.valueof(ActualTimeMin) > 15 && integer.valueof(ActualTimeMin) <= 29 ) {
            formattedTime = ActualTimeHour + ':' + '15' + ActualTimePeriod;
        } else if(integer.valueof(ActualTimeMin) > 30 && integer.valueof(ActualTimeMin) <= 44 ) {
            formattedTime = ActualTimeHour + ':' + '30' + ActualTimePeriod;
        } else if(integer.valueof(ActualTimeMin) > 45 && integer.valueof(ActualTimeMin) <= 59 ) {
            formattedTime = ActualTimeHour + ':' + '45' + ActualTimePeriod;
        }
        return formattedTime;
	}
	
	public static List<String> getLeaveFieldsList() {
	   return new List<String>{ 'Id', 'Name', 'Technician__c', 'From__c', 'To__c', 'From_Date__c', 'To_Date__c'};
   	}
}