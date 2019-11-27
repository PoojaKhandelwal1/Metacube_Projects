public without sharing class TechnicianDetailWrapper implements Comparable {
    
    public String Id;
    public String Name;
    public String Role;
    public String NameInitials;
    public String WorkingDays;
    public Decimal AvailableHours;
    public Decimal BookedHours;
    public Boolean IsFullDayLeave;
    public Boolean HasPartialDayLeave; 
    public Decimal AvailableHoursMorning;
    public Decimal AvailableHoursAfternoon;
    public String AvailableHoursMorningColor;
    public String AvailableHoursAfternoonColor;
    public Decimal HoursForSorting;
    public List<PartialLeaveWrapper> LeaveList;
    
    public TechnicianDetailWrapper(Technician__c technicianRec) {
		populateDefaultInfo(technicianRec);
		this.WorkingDays = technicianRec.Working_Days__c;
	}
	
    public TechnicianDetailWrapper(Technician__c technicianRec, String day, List<Shop_Settings__c> shopSettingList, DateTime currentDate) {
        populateDefaultInfo(technicianRec);
        populateHours(technicianRec, day, shopSettingList, currentDate);
    	populateLeaveData(technicianRec, shopSettingList, currentDate);
    }
    
    public TechnicianDetailWrapper(Technician__c technicianRec, String day, List<Shop_Settings__c> shopSettingList, DateTime currentDate, Decimal estimatedHours) {
        populateDefaultInfo(technicianRec);
        populateAvailableHours(technicianRec, day, shopSettingList, currentDate);
        populateAvailableHoursColor(estimatedHours);
    }
    
    public Integer compareTo(Object compareToObj) {
        TechnicianDetailWrapper compareToWrapperObj = (TechnicianDetailWrapper)compareToObj;
        if (HoursForSorting == compareToWrapperObj.HoursForSorting) return 0;
        if(HoursForSorting > compareToWrapperObj.HoursForSorting) return -1;
        return 1;
    }
    
    private void populateLeaveData(Technician__c technicianRec, List<Shop_Settings__c> shopSettingList, DateTime currentDate) {
        this.LeaveList = new List<PartialLeaveWrapper>();
        Date currentDateOnly = date.newinstance(currentDate.year(), currentDate.month(), currentDate.day());
        for(Leave__c leaveRec : technicianRec.Leaves__r) {
            this.LeaveList.add(new PartialLeaveWrapper(leaveRec, currentDateOnly, shopSettingList));
        }
        this.HasPartialDayLeave = (this.LeaveList.size() > 0);
        
        if(this.LeaveList.size() > 1) {
            for(Integer i = 0; i < this.LeaveList.size(); i++) {
                for(Integer j = 0; j < this.LeaveList.size(); j++) {
                    if(i != j && (DateTimeUtility.getTimeFromString(this.LeaveList[i].FromTime) <= DateTimeUtility.getTimeFromString(this.LeaveList[j].ToTime) && 
                            DateTimeUtility.getTimeFromString(this.LeaveList[i].ToTime) >= DateTimeUtility.getTimeFromString(this.LeaveList[j].FromTime))) {
                        if(DateTimeUtility.getTimeFromString(this.LeaveList[i].FromTime) > DateTimeUtility.getTimeFromString(this.LeaveList[j].FromTime)) {
                            this.LeaveList[i].FromTime = this.LeaveList[j].FromTime;
                        }
                        if(DateTimeUtility.getTimeFromString(this.LeaveList[i].ToTime) < DateTimeUtility.getTimeFromString(this.LeaveList[j].ToTime)) {
                            this.LeaveList[i].ToTime = this.LeaveList[j].ToTime;
                        }
                        this.LeaveList.remove(j);
                        j--;
                    }
                }
            }
        }
    }
    
    private void populateDefaultInfo(Technician__c technicianRec) {
        this.Id = technicianRec.Id;
        this.Role = technicianRec.Role__c;
        this.Name = technicianRec.Technician_Name__c;
        this.NameInitials = ((technicianRec.First_Name__c.length() > 0) ? technicianRec.First_Name__c.subString(0, 1) : '') +
                            ((technicianRec.Last_Name__c.length() > 0) ? technicianRec.Last_Name__c.subString(0, 1) : '');
    }
    
    private void populateHours(Technician__c technicianRec, String day, List<Shop_Settings__c> shopSettingList, DateTime currentDate) {
        this.IsFullDayLeave = false;
        populateTotalAndAvailableHours(technicianRec, day, shopSettingList, currentDate, true);
        this.BookedHours = 0;
        for(LookedUpFromActivity scheduleEventRec : technicianRec.Activities__r) {
            this.BookedHours += (scheduleEventRec.Estimated_Hours__c != null ? scheduleEventRec.Estimated_Hours__c : 0);
        }
    }
    
    private void populateAvailableHours(Technician__c technicianRec, String day, List<Shop_Settings__c> shopSettingList, DateTime currentDate) {
        populateTotalAndAvailableHours(technicianRec, day, shopSettingList, currentDate, false);
        if(this.AvailableHoursMorning < 0) {
            this.AvailableHoursMorning = 0;
        }
        if(this.AvailableHoursAfternoon < 0) {
            this.AvailableHoursAfternoon = 0;
        }
    }
    
    private void populateTotalAndAvailableHours(Technician__c technicianRec, String day, List<Shop_Settings__c> shopSettingList, DateTime currentDate,
                                                    Boolean isPopulateTotalHours) {
        if(isWorkingDayForTechnician(technicianRec, day) && shopSettingList.size() > 0) {
            Time shopFromTime = DateTimeUtility.getTimeFromString(shopSettingList[0].From_Time__c);
            Time shopToTime = DateTimeUtility.getTimeFromString(shopSettingList[0].To_Time__c);
            
            Decimal totalAvailableHoursMorning = DateTimeUtility.getTimeBySegment('AM', shopSettingList[0].From_Time__c, shopSettingList[0].To_Time__c);
            Decimal totalAvailableHoursAfternoon = DateTimeUtility.getTimeBySegment('PM', shopSettingList[0].From_Time__c, shopSettingList[0].To_Time__c);
            Decimal totalShopHours = 0;
            if(isPopulateTotalHours) {
                totalShopHours = totalAvailableHoursMorning + totalAvailableHoursAfternoon;
            }
            
            Decimal leaveDurationHoursMorning = 0;
            Decimal leaveDurationHoursAfternoon = 0;
            Date currentDateOnly = date.newinstance(currentDate.year(), currentDate.month(), currentDate.day());
            
            if(technicianRec.Leaves__r.size() > 0) {
                Time leaveFromTime, leaveToTime;
                String fromTimeStr, toTimeStr;
                for(Leave__c leaveRec : technicianRec.Leaves__r) {
					if(leaveRec.From_Date__c < currentDate && leaveRec.To_Date__c > currentDate.addDays(1)) {
                        leaveDurationHoursMorning = totalAvailableHoursMorning;
                        leaveDurationHoursAfternoon = totalAvailableHoursAfternoon;
                        fromTimeStr = toTimeStr = null;
                        break;
                    } else {
                        if(leaveFromTime == null && leaveToTime == null) {
                            leaveFromTime = DateTimeUtility.getTimeFromString(leaveRec.From__c.format('h:mma'));
                            leaveToTime = DateTimeUtility.getTimeFromString(leaveRec.To__c.format('h:mma'));
                            
                            fromTimeStr = (leaveFromTime > shopFromTime && leaveRec.From_Date__c == currentDateOnly) ? leaveRec.From__c.format('h:mma') : shopSettingList[0].From_Time__c;
                            toTimeStr = (leaveToTime < shopToTime && leaveRec.To_Date__c == currentDateOnly) ? leaveRec.To__c.format('h:mma') : shopSettingList[0].To_Time__c;
                        } else {
                            if(leaveFromTime < DateTimeUtility.getTimeFromString(leaveRec.To__c.format('h:mma')) && leaveToTime > DateTimeUtility.getTimeFromString(leaveRec.From__c.format('h:mma'))) {
                                if(leaveToTime < DateTimeUtility.getTimeFromString(leaveRec.To__c.format('h:mma'))) {
                                    leaveToTime = DateTimeUtility.getTimeFromString(leaveRec.To__c.format('h:mma'));
                                    toTimeStr = (leaveToTime < shopToTime && leaveRec.To_Date__c == currentDateOnly) ? leaveRec.To__c.format('h:mma') : shopSettingList[0].To_Time__c;
                                }
                            } else {
                                leaveDurationHoursMorning += DateTimeUtility.getTimeBySegment('AM', fromTimeStr, toTimeStr);
                                leaveDurationHoursAfternoon += DateTimeUtility.getTimeBySegment('PM', fromTimeStr, toTimeStr);
                                
                                leaveFromTime = DateTimeUtility.getTimeFromString(leaveRec.From__c.format('h:mma'));
                                leaveToTime = DateTimeUtility.getTimeFromString(leaveRec.To__c.format('h:mma'));
                                
                                fromTimeStr = (leaveFromTime > shopFromTime && leaveRec.From_Date__c == currentDateOnly) ? leaveRec.From__c.format('h:mma') : shopSettingList[0].From_Time__c;
                                toTimeStr = (leaveToTime < shopToTime && leaveRec.To_Date__c == currentDateOnly) ? leaveRec.To__c.format('h:mma') : shopSettingList[0].To_Time__c;
                            }
                        }
                    }
                }
                if(fromTimeStr != null && toTimeStr != null) {
                    leaveDurationHoursMorning += DateTimeUtility.getTimeBySegment('AM', fromTimeStr, toTimeStr);
                    leaveDurationHoursAfternoon += DateTimeUtility.getTimeBySegment('PM', fromTimeStr, toTimeStr);
                } else {
                    if(isPopulateTotalHours) {
                        this.IsFullDayLeave = true;
                    }
                }
            }
            if(isPopulateTotalHours) {
                this.AvailableHours = totalShopHours - (leaveDurationHoursMorning + leaveDurationHoursAfternoon);
                if(this.AvailableHours == 0) {
                    this.IsFullDayLeave = true;
                }
            } else {
                Decimal bookedHoursMorning = 0;
                Decimal bookedHoursAfternoon = 0;
                for(LookedUpFromActivity scheduleEventRec : technicianRec.Activities__r) {
                    if(scheduleEventRec.StartDateTime != null && scheduleEventRec.EndDateTime != null) {
                        String bookedFromTime = scheduleEventRec.StartDateTime.format('h:mma');
                        String bookedToTime = scheduleEventRec.EndDateTime.format('h:mma');
                        bookedHoursMorning += (DateTimeUtility.getTimeBySegment('AM', bookedFromTime, bookedToTime));
                        bookedHoursAfternoon += (DateTimeUtility.getTimeBySegment('PM', bookedFromTime, bookedToTime));
                    }
                }
                
                this.AvailableHoursMorning = totalAvailableHoursMorning - leaveDurationHoursMorning - bookedHoursMorning;
                this.AvailableHoursAfternoon = totalAvailableHoursAfternoon - leaveDurationHoursAfternoon - bookedHoursAfternoon;
            }
		} else {
            if(isPopulateTotalHours) {
                this.AvailableHours = 0;
            } else {
                this.AvailableHoursMorning = 0;
                this.AvailableHoursAfternoon = 0;
            }
        }
    }
    
    private void populateAvailableHoursColor(Decimal estimatedHours) {
        if(this.AvailableHoursMorning == 0) {
            this.AvailableHoursMorningColor = '#97A0AF';
        } else if(this.AvailableHoursMorning >= estimatedHours) {
            this.AvailableHoursMorningColor = '#344563';
        } else {
            this.AvailableHoursMorningColor = '#ff9920';
        }
        
        if(this.AvailableHoursAfternoon == 0) {
            this.AvailableHoursAfternoonColor = '#97A0AF';
        } else if(this.AvailableHoursAfternoon >= estimatedHours) {
            this.AvailableHoursAfternoonColor = '#344563';
        } else {
            this.AvailableHoursAfternoonColor = '#ff9920';
        }
    }
    
	private Boolean isWorkingDayForTechnician(Technician__c techRec, String day) {
	    Boolean isWorking = false;
	    if(String.isNotBlank(techRec.Working_Days__c) && techRec.Working_Days__c.contains(day)) {
	        isWorking = true;
	    }
	    return isWorking;
	}
	
    public static List<String> getTechnicianFieldsList() {
        return new List<String>{'Role__c', 'Working_Days__c', 'Technician_Name__c', 'First_Name__c', 'Last_Name__c'};
    }
    
    public class PartialLeaveWrapper {
        public String Type;
        public String FromTime;
        public String ToTime;
        
        public PartialLeaveWrapper(Leave__c leaveRec, Date currentDateOnly, List<Shop_Settings__c> shopSettingList) {
            this.Type = leaveRec.Name;
            if(leaveRec.From_Date__c < currentDateOnly) {
                this.FromTime = (shopSettingList.size() > 0) ? shopSettingList[0].From_Time__c : '';
            } 
            if(leaveRec.To_Date__c > currentDateOnly) {
                this.ToTime = '11:59PM';
            }
            if(this.FromTime == null) {
                if(shopSettingList.size() > 0 && DateTimeUtility.getTimeFromString(leaveRec.From__c.format('h:mma')) < DateTimeUtility.getTimeFromString(shopSettingList[0].From_Time__c)) {
                    this.FromTime = shopSettingList[0].From_Time__c;
                } else {
                    this.FromTime = leaveRec.From__c.format('h:mma');
                }
            }
            if(this.ToTime == null) {
                if(shopSettingList.size() > 0 && DateTimeUtility.getTimeFromString(leaveRec.To__c.format('h:mma')) < DateTimeUtility.getTimeFromString(shopSettingList[0].From_Time__c)) {
                    this.ToTime = shopSettingList[0].From_Time__c;
                } else {
                    this.ToTime = leaveRec.To__c.format('h:mma');
                }
            }
        }
    }
}