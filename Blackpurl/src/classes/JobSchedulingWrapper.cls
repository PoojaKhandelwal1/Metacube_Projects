/**
 * Author: Pooja Khandelwal
 * Since: Jul 27, 2017
 * Name: ScheduleWrapper
 * Description: Apex class to create scedule json object
 **/
public without sharing class JobSchedulingWrapper {
    public String Id;
    public String Title;
    public String StartDate;
    public String EndDate;
    public String StartTime;
    public String EndTime;
    public String ActualStartTime;
    public String ActualEndTime;
    public String Subject;
    public String Type;
    public String CurrentView;
    public String StartCalendarViewDate;
    public String EndCalendarViewDate;
    public String StartCalendarViewTime;
    public String EndCalendarViewTime;
    public Integer CalendarViewMonthNumber;
    public String Notes;
    public String COHeaderId;
    public Boolean AppointmentFilter;
    public Boolean AppointmentwithserviceFilter;
    public Boolean ReminderFilter;
    public Boolean IsAllDayEvent;
    public String CalculatedStartDate;
    public String CalculatedEndDate;
    public String CustomerName;
	public String CustomerOrderNumber;
	public String SchedulingDateFormat { get{return Constants.localeToDateTimeFmtMap.containsKey(UserInfo.getLocale())? Constants.localeToDateTimeFmtMap.get(UserInfo.getLocale()): Constants.localeToDateTimeFmtMap.get('en_AU'); } private set;}
    
    public JobSchedulingWrapper(Event scheduleEventRec){
        String[] datetimeValue ; 
        this.Id = scheduleEventRec.Id;
        this.Title = scheduleEventRec.Title__c;
        if(scheduleEventRec.Notes__c == null)	{
        	this.Notes = '';
        }else	{
        	this.Notes = scheduleEventRec.Notes__c; 
        	this.Notes += scheduleEventRec.AdditionalNotes__c != null ? scheduleEventRec.AdditionalNotes__c : '';
        }
        this.Subject = scheduleEventRec.Subject; 
        this.Type = scheduleEventRec.Type; 
        this.COHeaderId = scheduleEventRec.WhatId;
        
        List<String> ActualTimeHourAndMin = new List<String>();
        String ActualTimeHour = '';
        String ActualTimeMin = '';
        String ActualTimePeriod = ''; 
        this.IsAllDayEvent = scheduleEventRec.IsMultiDayEvent__c;
        if(scheduleEventRec.StartDateTime != null){ 
            //System.assert(false, SchedulingDateFormat);
            datetimeValue = String.valueOf(scheduleEventRec.StartDateTime.format(SchedulingDateFormat + '-h:mma')).Split('-'); 
            this.StartDate = datetimeValue[0];
            this.ActualStartTime = datetimeValue[1]; 
            
            ActualTimeHourAndMin = ActualStartTime.Split(':');
            ActualTimeHour = ActualTimeHourAndMin[0];
            ActualTimeMin = ActualTimeHourAndMin[1].substring(0, ActualTimeHourAndMin[1].length()-2);
            ActualTimePeriod = ActualTimeHourAndMin[1].substring(ActualTimeHourAndMin[1].length()-2, ActualTimeHourAndMin[1].length());
            
            /**if(integer.valueof(ActualTimeMin) > 00 && integer.valueof(ActualTimeMin) <= 29 )	{
            	this.StartTime = ActualTimeHour + ':' + '30' + ActualTimePeriod;
            } else if(integer.valueof(ActualTimeMin) > 30 && integer.valueof(ActualTimeMin) <= 59 )	{
            	if(integer.valueof(ActualTimeHour) == 11)	{
            		if(ActualTimePeriod == 'AM'){
            			ActualTimePeriod = 'PM';
            		}else if(ActualTimePeriod == 'PM'){
            			ActualTimePeriod = 'AM';
            		}
            	}
            	this.StartTime = String.valueOf(integer.valueof(ActualTimeHour) + 1) + ':' + '00' + ActualTimePeriod;
            }else if(integer.valueof(ActualTimeMin) == 00 || integer.valueof(ActualTimeMin) == 30 ){
            	this.StartTime = ActualStartTime;
            }*/
            
            if(integer.valueof(ActualTimeMin) > 00 && integer.valueof(ActualTimeMin) <= 29 )	{
            	this.StartTime = ActualTimeHour + ':' + '00' + ActualTimePeriod;
            } else if(integer.valueof(ActualTimeMin) > 30 && integer.valueof(ActualTimeMin) <= 59 )	{
            	this.StartTime = ActualTimeHour + ':' + '30' + ActualTimePeriod;
            }else if(integer.valueof(ActualTimeMin) == 00 || integer.valueof(ActualTimeMin) == 30 ){
            	this.StartTime = ActualStartTime;
            }
        }
        if(scheduleEventRec.EndDateTime != null){
            datetimeValue = String.valueOf(scheduleEventRec.Enddatetime.format(SchedulingDateFormat + '-h:mma')).Split('-'); 
            this.EndDate = datetimeValue[0];
            this.ActualEndTime = datetimeValue[1];
            
            ActualTimeHourAndMin = ActualEndTime.Split(':');
            ActualTimeHour = ActualTimeHourAndMin[0];
            ActualTimeMin = ActualTimeHourAndMin[1].substring(0, ActualTimeHourAndMin[1].length()-2);
            ActualTimePeriod = ActualTimeHourAndMin[1].substring(ActualTimeHourAndMin[1].length()-2, ActualTimeHourAndMin[1].length());
            
            if(integer.valueof(ActualTimeMin) > 00 && integer.valueof(ActualTimeMin) <= 29 )	{
            	this.EndTime = ActualTimeHour + ':' + '30' + ActualTimePeriod;
            } else if(integer.valueof(ActualTimeMin) > 30 && integer.valueof(ActualTimeMin) <= 59 )	{
            	if(integer.valueof(ActualTimeHour) == 11)	{
            		if(ActualTimePeriod == 'AM'){
            			ActualTimePeriod = 'PM';
            		}else if(ActualTimePeriod == 'PM'){
            			ActualTimePeriod = 'AM';
            		}
            	}
            	this.EndTime = String.valueOf(integer.valueof(ActualTimeHour) + 1) + ':' + '00' + ActualTimePeriod;
            }else if(integer.valueof(ActualTimeMin) == 00 || integer.valueof(ActualTimeMin) == 30 ){
            	this.EndTime = ActualEndTime;
            }
        }
    }
    
    public JobSchedulingWrapper(Event scheduleEventRec, DateTime startDate, DateTime endDate){
        String[] datetimeValue ; 
        this.Id = scheduleEventRec.Id;
        this.Title = scheduleEventRec.Title__c;
        
        if(scheduleEventRec.Notes__c == null)	{
        	this.Notes = '';
        }else	{
        	this.Notes = scheduleEventRec.Notes__c; 
        }
        this.Subject = scheduleEventRec.Subject; 
        this.Type = scheduleEventRec.Type; 
        this.COHeaderId = scheduleEventRec.WhatId;
        
        List<String> ActualTimeHourAndMin = new List<String>();
        String ActualTimeHour = '';
        String ActualTimeMin = '';
        String ActualTimePeriod = ''; 
        this.IsAllDayEvent = scheduleEventRec.IsMultiDayEvent__c;
        if(scheduleEventRec.StartDateTime != null){ 
            //System.assert(false, scheduleEventRec.StartDateTime);
            datetimeValue = String.valueOf(scheduleEventRec.StartDateTime.format(SchedulingDateFormat + '-h:mma')).Split('-'); 
            this.StartDate = datetimeValue[0]; //
            this.ActualStartTime = datetimeValue[1]; 
            
            if(startDate >= scheduleEventRec.StartDateTime) { //
        		this.CalculatedStartDate = String.valueOf(startDate.format(SchedulingDateFormat + '-h:mma')).Split('-')[0];
        	} else {
        		this.CalculatedStartDate = this.StartDate;
        	}
            
            ActualTimeHourAndMin = ActualStartTime.Split(':');
            ActualTimeHour = ActualTimeHourAndMin[0];
            ActualTimeMin = ActualTimeHourAndMin[1].substring(0, ActualTimeHourAndMin[1].length()-2);
            ActualTimePeriod = ActualTimeHourAndMin[1].substring(ActualTimeHourAndMin[1].length()-2, ActualTimeHourAndMin[1].length());
            
            if(integer.valueof(ActualTimeMin) > 00 && integer.valueof(ActualTimeMin) <= 29 )	{
            	this.StartTime = ActualTimeHour + ':' + '30' + ActualTimePeriod;
            } else if(integer.valueof(ActualTimeMin) > 30 && integer.valueof(ActualTimeMin) <= 59 )	{
            	if(integer.valueof(ActualTimeHour) == 11)	{
            		if(ActualTimePeriod == 'AM'){
            			ActualTimePeriod = 'PM';
            		}else if(ActualTimePeriod == 'PM'){
            			ActualTimePeriod = 'AM';
            		}
            	}
            	this.StartTime = String.valueOf(integer.valueof(ActualTimeHour) + 1) + ':' + '00' + ActualTimePeriod;
            }else if(integer.valueof(ActualTimeMin) == 00 || integer.valueof(ActualTimeMin) == 30 ){
            	this.StartTime = ActualStartTime;
            }
        }
        if(scheduleEventRec.EndDateTime != null){
            datetimeValue = String.valueOf(scheduleEventRec.Enddatetime.format(SchedulingDateFormat + '-h:mma')).Split('-'); 
            this.EndDate = datetimeValue[0]; //
            this.ActualEndTime = datetimeValue[1];
            
            if(endDate <= scheduleEventRec.EndDateTime) { //
        		this.CalculatedEndDate = String.valueOf(endDate.format(SchedulingDateFormat + '-h:mma')).Split('-')[0];
        	} else {
        		this.CalculatedEndDate = this.EndDate;
        	}
            
            ActualTimeHourAndMin = ActualEndTime.Split(':');
            ActualTimeHour = ActualTimeHourAndMin[0];
            ActualTimeMin = ActualTimeHourAndMin[1].substring(0, ActualTimeHourAndMin[1].length()-2);
            ActualTimePeriod = ActualTimeHourAndMin[1].substring(ActualTimeHourAndMin[1].length()-2, ActualTimeHourAndMin[1].length());
            
            if(integer.valueof(ActualTimeMin) > 00 && integer.valueof(ActualTimeMin) <= 29 )	{
            	this.EndTime = ActualTimeHour + ':' + '30' + ActualTimePeriod;
            } else if(integer.valueof(ActualTimeMin) > 30 && integer.valueof(ActualTimeMin) <= 59 )	{
            	if(integer.valueof(ActualTimeHour) == 11)	{
            		if(ActualTimePeriod == 'AM'){
            			ActualTimePeriod = 'PM';
            		}else if(ActualTimePeriod == 'PM'){
            			ActualTimePeriod = 'AM';
            		}
            	}
            	this.EndTime = String.valueOf(integer.valueof(ActualTimeHour) + 1) + ':' + '00' + ActualTimePeriod;
            }else if(integer.valueof(ActualTimeMin) == 00 || integer.valueof(ActualTimeMin) == 30 ){
            	this.EndTime = ActualEndTime;
            }
        }
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> eventFieldList = new List<String>{ 'Id', 
                                                        'Subject',
                                                        'StartDateTime',
                                                        'EndDateTime',
                                                        'Type',
                                                        'Title__c',
                                                        'Notes__c',
                                                        'WhatId',
                                                        'IsMultiDayEvent__c',
                                                        'AdditionalNotes__c'
                                                        /**,
                                                        'CO_Header__r.Name',
                                                        'CO_Header__r.Customer__r.Name'*/
                                                };
        return eventFieldList;
    }
    
    public static List<String> getCOHeaderfieldsList(){
        List<String> COHeaderfieldsList = new List<String>{ 'Id',
        												'Customer__c', 
                                                        'Customer__r.Name',
                                                        'Name'
                                                	  };
        return COHeaderfieldsList;
    }
    
     public static List<String> getSOHeaderfieldsList(){
        List<String> SOHeaderfieldsList = new List<String>{ 'Id', 
                                                        'Name__c',
                                                        'Customer_Owned_Unit__c',
                                                        'Customer_Owned_Unit__r.Year__c',
                                                        'Customer_Owned_Unit__r.Unit_Make__r.Name',
                                                        'Customer_Owned_Unit__r.Unit_Model__r.Name__c',
                                                        'Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c',
                                                        'Transaction_Type__r.Type__c',
                                                        'Work_Status__c',
                                                        'SO_Concern__c'
                                                };
        return SOHeaderfieldsList;
    }
    
    public class COHeaderWrapper 	{
    	public String COHeaderId;
    	public String CustomerId;
	    public String CustomerName;
	    public String CustomerOrderNumber;
	    public List<SOWrapper> ServiceOrderList;
	    
	    public COHeaderWrapper(CO_Header__c COHeaderRec){
	    	this.COHeaderId =  COHeaderRec.Id;
	    	this.CustomerId =  COHeaderRec.Customer__c;
	    	this.CustomerName =  COHeaderRec.Customer__r.Name;
	    	this.CustomerOrderNumber =  COHeaderRec.Name;
	    	ServiceOrderList = new List<SOWrapper>();
	    	for(Service_Order_Header__c soHeaderRec: COHeaderRec.Service_Order_Headers__r)	{
	    		ServiceOrderList.add(new SOWrapper(soHeaderRec));
	    	}
	    }
	    
    }
    
    public class SOWrapper 	{
    	public String SOHeaderId;
	    public String SectionName;
    	public String UnitId;
    	public String Year;
    	public String Make;
    	public String Model;
    	public String SubModel;
    	public String JobType;
    	public String JobStatus;
    	public String ServiceNeeded;
    	
    	public SOWrapper(Service_Order_Header__c soHeaderRec){
	    	this.SOHeaderId =  soHeaderRec.Id;
	    	this.SectionName =  soHeaderRec.Name__c;
	    	this.UnitId =  soHeaderRec.Customer_Owned_Unit__c;
	    	this.Year =  (soHeaderRec.Customer_Owned_Unit__r.Year__c  != null) ? String.valueOf(soHeaderRec.Customer_Owned_Unit__r.Year__c) :'';
	    	this.Make =  (soHeaderRec.Customer_Owned_Unit__r.Unit_Make__r.Name != null) ? soHeaderRec.Customer_Owned_Unit__r.Unit_Make__r.Name :'';
	    	this.Model =  (soHeaderRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c != null) ? soHeaderRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c :'';
	    	this.SubModel =  soHeaderRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c;
	    	this.JobType =  (soHeaderRec.Transaction_Type__r.Type__c != null) ? soHeaderRec.Transaction_Type__r.Type__c : '';
	    	this.JobStatus =  soHeaderRec.Work_Status__c;
	    	this.ServiceNeeded =  (soHeaderRec.SO_Concern__c != null) ? soHeaderRec.SO_Concern__c :'';
	    }
    }
    
    
}