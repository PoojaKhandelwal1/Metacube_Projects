/**
 * Author: Tarun Khandelwal
 * Since: Nov 03, 2017 
 * Name: PayrollWrapper
 * Description: Used to handle all JSON to Payroll Clocking
**/
public with sharing class PayrollWrapper implements Comparable {
    public String Id;
    public String TechnicianId;
    public String TechnicianName;
    public String TechnicianFirstName;
    public String TechnicianLastName;
    public String FormattedTotalTime;
    public String StartDate;
    public String TimeIn;
    public String TimeOut;
    public Decimal TimeInHour;
    public Decimal TimeInMinute;
    public Boolean IsClockedOn;
    
    public PayrollWrapper(Technician__c technicianRec) {
        this.TechnicianId = technicianRec.Id;
        this.TechnicianName = technicianRec.Technician_Name__c;
        this.TechnicianFirstName = technicianRec.First_Name__c;
        this.TechnicianLastName = technicianRec.Last_Name__c;
        
        if(technicianRec.Payroll_Times__r.size() > 0) {
            for(Payroll_Time__c payrollRec : technicianRec.Payroll_Times__r) { // There will be only one record
                this.IsClockedOn = payrollRec.Is_Clocked_On__c;
                this.Id = payrollRec.Id;
                this.FormattedTotalTime = payrollRec.Formatted_Total_Time__c;
            }
        } else {
            this.IsClockedOn = false;
            this.FormattedTotalTime = '00h00min';
        }
    }
    
    public PayrollWrapper(Payroll_Time__c payrollTimeRec) {
        this.Id = payrollTimeRec.Id;
        this.TechnicianId = payrollTimeRec.Technician__c;
        this.TechnicianName = payrollTimeRec.Technician__r.Technician_Name__c;
        this.TechnicianFirstName = payrollTimeRec.Technician__r.First_Name__c;
        this.TechnicianLastName = payrollTimeRec.Technician__r.Last_Name__c;
        this.StartDate = (payrollTimeRec.Start_Date__c != null) ? 
                                payrollTimeRec.Start_Date__c.format(Constants.localeToDateTimeFmtMap.get(UserInfo.getLocale())) : '';
        this.TimeIn = (payrollTimeRec.Start_Date__c != null) ? payrollTimeRec.Start_Date__c.format('h:mm a') : '';
        this.TimeOut = (payrollTimeRec.End_Date__c != null) ? payrollTimeRec.End_Date__c.format('h:mm a') : '';     
        this.FormattedTotalTime = payrollTimeRec.Formatted_Total_Time__c;                
        
        this.TimeInHour = (payrollTimeRec.Start_Date__c != null) ? payrollTimeRec.Start_Date__c.hour() : null;
		this.TimeInMinute = (payrollTimeRec.Start_Date__c != null) ? payrollTimeRec.Start_Date__c.minute() : null;
    }
    
    public static List<String> getPayrollFieldsList() {
        List<String> PayrollFields = new List<String>{ 'Id',
                                                        'Name',
                                                        'Technician__c',
                                                        'Technician__r.Technician_Name__c',
                                                        'Technician__r.First_Name__c',
                                                        'Technician__r.Last_Name__c',
                                                        'Start_Date__c',
                                                        'End_Date__c',
                                                        'Formatted_Total_time__c',
                                                        'Total_time__c',
                                                        'Is_Clocked_On__c'
                                                };
        return PayrollFields;
    }
    
    public Integer compareTo(Object compareToObj) {
        PayrollWrapper payrollCompareToObj = (PayrollWrapper) compareToObj;
        Integer returnVal = 0;
        if(this.IsClockedOn != null && this.TimeIn == null) {
	        if(String.valueOf(this.IsClockedOn) < String.valueOf(payrollCompareToObj.IsClockedOn)) {
	            returnVal = 1;
	        } else if(String.valueOf(this.IsClockedOn) > String.valueOf(payrollCompareToObj.IsClockedOn)){
	            returnVal = -1;
	        } else {
	            if(payrollCompareToObj.TechnicianName < this.TechnicianName) {
	                returnVal = -1;
	            } else {
	                returnVal = 0;
	            }
	        }
        } else {
        	if(this.TechnicianName > payrollCompareToObj.TechnicianName) {
        		returnVal = 1;
        	} else if(this.TechnicianName < payrollCompareToObj.TechnicianName){
        		returnVal = -1; 
        	} else {
        		if(this.StartDate > payrollCompareToObj.StartDate) {
        			returnVal = 1;
        		} else if(this.StartDate < payrollCompareToObj.StartDate) {
        			returnVal = -1;
        		} else {
        			if(this.TimeInHour > payrollCompareToObj.TimeInHour) {
        				returnVal = 1;
        			} else if(this.TimeInHour < payrollCompareToObj.TimeInHour) {
        				returnVal = -1;
        			} else {
        				if(this.TimeInMinute > payrollCompareToObj.TimeInMinute) {
	        				returnVal = 1;
	        			} else if(this.TimeInMinute < payrollCompareToObj.TimeInMinute) {
	        				returnVal = -1;
	        			} else {
	        				if(this.TimeIn > payrollCompareToObj.TimeIn) {
		        				returnVal = 1;
		        			} else if(this.TimeIn < payrollCompareToObj.TimeIn) {
		        				returnVal = -1;
		        			} else {
		        				returnVal = 0;
		        			}
	        			}
        			}
        		}
        	}
        }
        return returnVal;
    }
    
    public class PayrollFilterWrapper {
    	
    	public String StartDate;
    	public String EndDate;
    	public String EmployeeId;
    	
    }
}