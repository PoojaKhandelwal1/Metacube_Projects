public class DateTimeUtility {
    
    public static DateTime getConvertedDateTime(String strDate, String strTime) {
        String stringDateTime = '';
        stringDateTime += strDate;
        stringDateTime += ' ' + strTime.substring(0, strTime.length()-2);
        String strTimePeriod = ' ' + strTime.substring(strTime.length()-2, strTime.length());
        stringDateTime += strTimePeriod;
        return DateTime.parse(stringDateTime);  
    }
    
    public static Time getTimeFromString(String timeString) {
    	List<String> ActualTimeHourAndMin = timeString.Split(':');
	   	Integer ActualTimeHour = Integer.valueOf(ActualTimeHourAndMin[0]);
	    Integer ActualTimeMin = Integer.valueOf(ActualTimeHourAndMin[1].substring(0, ActualTimeHourAndMin[1].length() - 2));
	    String ActualTimeHalf = ActualTimeHourAndMin[1].substring(ActualTimeHourAndMin[1].length() - 2, ActualTimeHourAndMin[1].length());
	    if(ActualTimeHalf == 'PM' && ActualTimeHour != 12) {
	    	ActualTimeHour = ActualTimeHour + 12;
	    }
	    return Time.newInstance(ActualTimeHour,ActualTimeMin,0,0);
    }
    
    public static Decimal getTimeDifference(DateTime fromDateTime, DateTime toDateTime) {
    	Long dt1Long = fromDateTime.getTime();
        Long dt2Long = toDateTime.getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long totalMinutes = (seconds / 60);
        Long hours = totalMinutes / 60;
        Long minutes = Math.mod(totalMinutes, 60);
        return Decimal.valueOf(hours + ';' + minutes);
    }
    
    public static Decimal getTimeBySegment(String segment, String fromTime, String toTime) {
    	Decimal availableHours = 0.00;
    	if(segment == 'AM') {
    		if(fromTime.contains('AM')) {
    			Time fromDateTime = getTimeFromString(fromTime);
    			Time toDateTime = Time.newInstance(12,0,0,0);
	        	if(toTime.contains('AM')) {
	        		toDateTime = getTimeFromString(toTime);
	        	}
        		Decimal hours = toDateTime.hour() - fromDateTime.hour();
        		Decimal minutes = toDateTime.minute() - fromDateTime.minute();
	        	availableHours = hours + minutes/60;
	        }
    	} else if(segment == 'PM') {
    		if(toTime.contains('PM')) {
    			Time fromDateTime = Time.newInstance(12,0,0,0);
    			Time toDateTime = getTimeFromString(toTime);
	        	if(fromTime.contains('PM')) {
	        		fromDateTime = getTimeFromString(fromTime);
	        	}
        		Decimal hours = toDateTime.hour() - fromDateTime.hour();
        		Decimal minutes = toDateTime.minute() - fromDateTime.minute();
	        	availableHours = hours + minutes/60;
	        }
    	}
    	if(availableHours < 0) {
    	    availableHours = 0;
    	}
    	return availableHours;
    }
    public static Map<String, List<DateTime>> getDaysDateMapForDateRange(DateTime startDateObject, DateTime endDateObject) {
    	Map<String, List<DateTime>> dayToDateMap = new Map<String, List<DateTime>>();
    	DateTime currentDateObject = startDateObject;
    	while(currentDateObject <= endDateObject) {
    		if(!dayToDateMap.containsKey(currentDateObject.format('EEEE'))) {
    			dayToDateMap.put(currentDateObject.format('EEEE'), new List<DateTime>());
    		} 
    		dayToDateMap.get(currentDateObject.format('EEEE')).add(currentDateObject);
    		currentDateObject =currentDateObject.addDays(1);
    	}
    	return dayToDateMap;
    } 
    public static Map<String, List<DateTime>> removeDateNotWithinRange(Map<String, List<DateTime>> dayToDateMap,DateTime startDate, DateTime fromDate) {
    	for(String dayName : dayToDateMap.keySet()) {
    		List<DateTime> dateList = dayToDateMap.get(dayName);
    		for(Integer j = 0; j < dateList.size(); j++ ) {
    			if(!(startDate <= dateList[j] &&  dateList[j] <= fromDate)) {
    				dateList.remove(j);
    			}
    		}
    		dayToDateMap.put(dayName, dateList );
    	}
    	return dayToDateMap;
    } 
    public static DateTime getDateTimeFromDate(Date dateValue) {
    	return datetime.newInstance(dateValue.year(),dateValue.month(),dateValue.day()); 
    }
    public static String getFormttedDateFromDateTime(DateTime dateTimeValue, String format) {
        return String.valueOf((dateTimeValue).format(format));
    }
    
    public static Date getDateFromFormattedDateStr(String dateStr) {
    	List<String> dateStringList = dateStr.split('/');
        return Date.newInstance(Integer.valueOf(dateStringList[2]), Integer.valueOf(dateStringList[1]), Integer.valueOf(dateStringList[0]));
    }
}