/**
 * Author: Richa Mittal
 * Since: Oct 16, 2017 
 * Name: JobClockingCtrl
 * Description: Used to handle all business logic related to Job Clocking
**/
global with sharing class JobClockingCtrl {
    
    global JobClockingCtrl (NewHomePageCtrl controller){}
    public JobClockingCtrl() {}

    @RemoteAction
    global static String getServiceJobs(String technicianId) {
        technicianId = BPUtility.getDecodedString(technicianId);
        Set<Id> soHeaderIdSetForTechnician = new Set<Id>();
        
        List<String> soHeaderStatusToInclude = new List<String>{'New', 'Ready', 'In Progress', 'On Hold', 'Complete'};
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Header__c> serviceJobList = 
                            [select Id, Work_Status__c, CO_Header__c, CO_Header__r.Name, CO_Header__r.CreatedDate, Transaction_Type__r.Code_Label__c, 
                                Customer_Owned_Unit__r.Make_Name__c, Customer_Owned_Unit__r.Model_Name__c, 
                                Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c, CO_Header__r.Customer_Name__c, 
                                Technician_Name__c, Hrs_Logged__c,Customer_Owned_Unit__r.Year__c,Name__c,SO_Concern__c,
                                (select Id, Technician__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, Technician__r.Active__c, Start_Date_Time__c, End_Date_Time__c, Time_Spent_d__c, Time_Spent_h__c, Time_Spent_m__c, Is_Removed__c from Hours_Logged__r order by CreatedDate desc)
                                from Service_Order_Header__c 
                                where Work_Status__c IN : soHeaderStatusToInclude]; //Work_Status__c != 'Invoiced' AND Work_Status__c != 'Reviewed' AND Work_Status__c != 'Signed Out'
    
        
        List<JobClockingWrapper> jobClockingWrapperList = new List<JobClockingWrapper>();
        for(Service_Order_Header__c serviceJob: serviceJobList) {
            JobClockingWrapper jobClockingWrapperRecord = new JobClockingWrapper(serviceJob, technicianId);
            jobClockingWrapperList.add(jobClockingWrapperRecord);
        }
        
        if(technicianId == null) {
            jobClockingWrapperList = JobClockingWrapper.sortServiceJobsForDefaultView(jobClockingWrapperList);
        } else {
            jobClockingWrapperList = JobClockingWrapper.sortServiceJobsForTechnicianView(jobClockingWrapperList, technicianId);
        }
        return BPUtility.getEncodedString(system.JSON.serialize(jobClockingWrapperList));
    }
    
    @RemoteAction
    global static String getTechnicianList(String soHeaderId) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Hours_Logged__c> assignedTechnicianList = [select Technician__c from Hours_Logged__c 
                                                            where Service_Order_Header__c =: soHeaderId
                                                                AND Task__c = NULL];
        Set<Id> technicianIdSet = new Set<Id>();
        for(Hours_Logged__c hourLoggedRec: assignedTechnicianList) {
            technicianIdSet.add(hourLoggedRec.Technician__c);
        }
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : SOHeaderWrapper.getTechnicianFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
         
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Technician__c WHERE Active__c= true ';
        query += 'AND Type__c = \'Technician\' ';
        if(soHeaderId != null) {
            query += 'AND Id NOT IN : technicianIdSet ';
        }
        
        query += 'Order by Technician_Name__c ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Technician__c> technicians = Database.query(query);
        List<SOHeaderWrapper.TechnicianWrapper> technicianObjList = new List<SOHeaderWrapper.TechnicianWrapper>();
        for(Technician__c technicianRec : technicians) {
            technicianObjList.add(new SOHeaderWrapper.TechnicianWrapper(technicianRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(technicianObjList));
    }
    
    @RemoteAction
    global static String assignTechnician(String soHeaderId, String technicianId, String technicianViewId) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        technicianId = BPUtility.getDecodedString(technicianId);
        technicianViewId = BPUtility.getDecodedString(technicianViewId);
        Hours_Logged__c recordToInsert = new Hours_Logged__c();
        recordToInsert.Technician__c = technicianId;
        recordToInsert.Service_Order_Header__c = soHeaderId;
        insert recordToInsert;
        
        if(technicianViewId == null) {
            return getServiceJob(soHeaderId, technicianViewId);
        } else {
            return getServiceJob(soHeaderId, technicianViewId);
        }
    }
    
    private static String getServiceJob(String soHeaderId, String technicianId) {
        List<String> soHeaderStatusToInclude = new List<String>{'New', 'Ready', 'In Progress', 'On Hold', 'Complete'};
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Header__c> serviceJobList = 
                            [select Id, Work_Status__c, CO_Header__c, CO_Header__r.Name, CO_Header__r.CreatedDate, Transaction_Type__r.Code_Label__c, 
                                Customer_Owned_Unit__r.Make_Name__c, Customer_Owned_Unit__r.Model_Name__c, 
                                Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c, CO_Header__r.Customer_Name__c, 
                                Technician_Name__c, Hrs_Logged__c,Customer_Owned_Unit__r.Year__c,Name__c,SO_Concern__c,
                                (select Id, Technician__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, Technician__r.Active__c, Start_Date_Time__c, End_Date_Time__c, Time_Spent_d__c, Time_Spent_h__c, Time_Spent_m__c, Is_Removed__c from Hours_Logged__r order by CreatedDate desc)
                                from Service_Order_Header__c 
                                where Work_Status__c IN : soHeaderStatusToInclude AND Id = :soHeaderId]; //Work_Status__c != 'Invoiced' AND Work_Status__c != 'Reviewed' AND Work_Status__c != 'Signed Out'
        
        return BPUtility.getEncodedString(system.JSON.serialize(new JobClockingWrapper(serviceJobList[0], technicianId)));
    }
    
    @RemoteAction
    global static String removeTechnician(String soHeaderId, String technicianId, String technicianViewId) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        technicianId = BPUtility.getDecodedString(technicianId);
        technicianViewId = BPUtility.getDecodedString(technicianViewId);
        if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Hours_Logged__c> hoursLoggedListForTechnician = [select Id, Start_Date_Time__c, End_Date_Time__c, Service_Order_Header__c, Technician__c 
                                                    from Hours_Logged__c
                                                    where Technician__c = :technicianId
                                                    AND Service_Order_Header__c = :soHeaderId];
        
        Boolean isCurrentlyClocked = false;
        Boolean isPreviouslyClocked = false;
        Boolean isAssigedButNotClocked = false;
        Hours_Logged__c hoursLoggedToDel = new Hours_Logged__c();
        for(Hours_Logged__c hrsLogged: hoursLoggedListForTechnician) {
            if(!isCurrentlyClocked && hrsLogged.Start_Date_Time__c != null && hrsLogged.End_Date_Time__c == null) {
                    isCurrentlyClocked = true;
                }
                if(!isPreviouslyClocked && hrsLogged.Start_Date_Time__c != null && hrsLogged.End_Date_Time__c != null) {
                    isPreviouslyClocked = true;
                }
                
                if(!isAssigedButNotClocked && hrsLogged.Start_Date_Time__c == null && hrsLogged.End_Date_Time__c == null) {
                    isAssigedButNotClocked = true;
                    hoursLoggedToDel = hrsLogged;
                }
        }
        if(isCurrentlyClocked) {
            throw new BlackPurlException('Technician is currently clocked on.');
        } else if(isPreviouslyClocked) {
            for(Hours_Logged__c hrsLogged: hoursLoggedListForTechnician) {
                hrsLogged.Is_Removed__c = true;
            }
            if(AccessControl.ifObjectFieldIsUpdateable('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update hoursLoggedListForTechnician;
            
        } else if(isAssigedButNotClocked) {
            if(AccessControl.ifObjectIsDeletable('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete hoursLoggedToDel;
        }
        
        /*if(technicianViewId == null) {
            return getServiceJobs(null);
        } else {
            return getServiceJobs(BPUtility.getEncodedString(technicianViewId));
        }*/
        if(technicianViewId == null) {
            return getServiceJob(soHeaderId, technicianViewId);
        } else {
            return getServiceJob(soHeaderId, technicianViewId);
        }
    }
    
    
    @RemoteAction
    global static String getHoursLoggedBySOHeaderId(String soHeaderId) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : SOHeaderWrapper.getHoursLoggedFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
         
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Hours_Logged__c WHERE Start_Date_Time__c != null ';
        
        query += 'AND Service_Order_Header__c =: soHeaderId ';
        
        String query1 = query + 'AND End_Date_Time__c = null ';
        String query2 = query + 'AND End_Date_Time__c != null ';
        
        query1 += 'Order by Start_Date_Time__c asc';
        query2 += 'Order by Start_Date_Time__c asc';
        
        if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Hours_Logged__c> hoursClockedList = Database.query(query1);
        List<Hours_Logged__c> hoursLoggedList = Database.query(query2);
        
        List<JobClockingWrapper.HoursLoggedInfo> sortedHoursLoggedInfoList = new List<JobClockingWrapper.HoursLoggedInfo>();
        String CurrentLoggedInUser = UserInfo.getUserId();
        
        for(Integer i=0;i<hoursClockedList.size();i++) {
            if(hoursClockedList[i].Id == CurrentLoggedInUser && hoursClockedList[i].End_Date_Time__c == null) {
                sortedHoursLoggedInfoList.add(new JobClockingWrapper.HoursLoggedInfo(hoursClockedList[i]));
                hoursClockedList.remove(i);
                break;
            }
        }
        
        for(Hours_Logged__c hoursLoggedRec : hoursClockedList) {
            sortedHoursLoggedInfoList.add(new JobClockingWrapper.HoursLoggedInfo(hoursLoggedRec));
        }
        for(Hours_Logged__c hoursLoggedRec : hoursLoggedList) {
            sortedHoursLoggedInfoList.add(new JobClockingWrapper.HoursLoggedInfo(hoursLoggedRec));
        }
        
        //system.assert(false, hoursLoggedInfoList);
        return BPUtility.getEncodedString(System.JSON.serialize(sortedHoursLoggedInfoList));
    }     
    
    @RemoteAction
    global static String getPayrollEntryForTechnician(String technicianId) {
        technicianId = BPUtility.getDecodedString(technicianId);
        List<Technician__c> technicianList = SOQLUtil.getTechnicianListWithPayroll(new Map<String, String>{'Id' => technicianId});
        String returnStr = '{"IsPayrollOn" : false, "PayrollId" : null}';
        if(technicianList.size() > 0 && technicianList[0].Payroll_Times__r.size() > 0 && technicianList[0].Payroll_Times__r[0].End_Date__c == null) {
            returnStr = '{"IsPayrollOn" : true, "PayrollId" : "' + technicianList[0].Payroll_Times__r[0].Id + '"}';
        }
        return BPUtility.getEncodedString(returnStr);
    }
    
    @RemoteAction
    global static String setPayrollForTechnician(String jsonString, String technicianId) {
        PayrollCtrl.saveClockStatus(jsonString);
        return getPayrollEntryForTechnician(technicianId);
    }
    
    @RemoteAction
    global static String setPayrollEntryForTechnician(String technicianId) {
        technicianId = BPUtility.getDecodedString(technicianId);
        List<Technician__c> technicianList = SOQLUtil.getTechnicianListWithPayroll(new Map<String, String>{'Id' => technicianId});
        String returnStr = '{"IsPayrollOn" : false}';
        if(technicianList.size() > 0 && technicianList[0].Payroll_Times__r.size() > 0) {
            returnStr = '{"IsPayrollOn" : true}';
        }
        return BPUtility.getEncodedString(returnStr);
    }
    
    @RemoteAction
    global static String clockONTechnician(String recordId, String technicianId) {
        recordId = BPUtility.getDecodedString(recordId);
        technicianId = BPUtility.getDecodedString(technicianId);
        try{
            List<Hours_Logged__c> hoursLoggedListToUpdate = clockOFFTechnicianforAllActiveJobs(technicianId);
            
            // Turn Payroll ON for that technician
            PayrollCtrl.payrollOnForTechnician(technicianId);
            
            String objectName = String.valueOf(Id.valueOf(recordId).getSobjectType());
            List<Hours_Logged__c> hoursLoggedList;
                
            if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                hoursLoggedList = [select Id, Service_Order_Header__c, Technician__c 
                                    from Hours_Logged__c
                                    where Technician__c = :technicianId
                                    AND Service_Order_Header__c = :recordId
                                    AND Start_Date_Time__c = null];
            }else if(objectName == Constants.NAMESPACE + 'Task__c') {
                hoursLoggedListToUpdate.addAll(clockOFFTaskforAllTechnician(recordId));
                hoursLoggedList = [select Id, Service_Order_Header__c, Technician__c 
                                    from Hours_Logged__c
                                    where Technician__c = :technicianId
                                    AND Task__c = :recordId
                                    AND Start_Date_Time__c = null];
            }
            
            Hours_Logged__c hoursLoggedRec = new Hours_Logged__c();
            if(hoursLoggedList.size() > 0){
                hoursLoggedRec.Id = hoursLoggedList[0].Id;
            }else{
                hoursLoggedRec.Technician__c = technicianId;
                if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                    hoursLoggedRec.Service_Order_Header__c = recordId;
                }else if(objectName == Constants.NAMESPACE + 'Task__c') {
                    hoursLoggedRec.Task__c = recordId;
                }
                
            }
            hoursLoggedRec.Start_Date_Time__c = System.now();
            hoursLoggedListToUpdate.add(hoursLoggedRec);
            upsert hoursLoggedListToUpdate;
            Set<Id> hoursLoggedIdSet = new Set<Id>();
            for(Hours_Logged__c hoursLogged  : hoursLoggedListToUpdate){
                hoursLoggedIdSet.add(hoursLogged.Id);
            }
            if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                CustomerOrderCtrl.calculateTechinicianHours(hoursLoggedIdSet, null);
                List<Service_Order_Header__c> soHeaderList = [select Work_Status__c
                                                                from Service_Order_Header__c
                                                                where Id = :recordId];
                if(soHeaderList.size() > 0 && soHeaderList[0].Work_Status__c != 'In Progress'){
                    soHeaderList[0].Work_Status__c = 'In Progress';
                    update soHeaderList;
                }
            }
            if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                return getServiceJobs(BPUtility.getEncodedString(technicianId));
            }else if(objectName == Constants.NAMESPACE + 'Task__c') {
                return getTaskListWithTechnicianId(BPUtility.getEncodedString(technicianId));
            }
            
        }catch(Exception e){
            system.assert(false, e);
        }
        return getServiceJobs(BPUtility.getEncodedString(technicianId));
    }
    
    @RemoteAction
    global static String clockOFFTechnician(String recordId, String technicianId) {
        // Deprecated
        return null;
    }
    
    
    @RemoteAction
    global static String clockOFFTechnicianWithNotes(String recordId, String technicianId, String notes) {
        recordId = BPUtility.getDecodedString(recordId);
        technicianId = BPUtility.getDecodedString(technicianId);
        notes = BPUtility.getDecodedString(notes);
        try{
            String objectName = String.valueOf(Id.valueOf(recordId).getSobjectType());
            List<Hours_Logged__c> hoursLoggedList;
            
            if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                hoursLoggedList = [select Id, Start_Date_Time__c, Service_Order_Header__c, Technician__c 
                                    from Hours_Logged__c
                                    where Technician__c = :technicianId
                                    AND Service_Order_Header__c = :recordId
                                    AND Start_Date_Time__c != null
                                    AND End_Date_Time__c = null];
            }else if(objectName == Constants.NAMESPACE + 'Task__c') { 
                hoursLoggedList = [select Id, Start_Date_Time__c, Service_Order_Header__c, Technician__c 
                                    from Hours_Logged__c
                                    where Technician__c = :technicianId
                                    AND Task__c = :recordId
                                    AND Start_Date_Time__c != null
                                    AND End_Date_Time__c = null];
            }
            
            if(hoursLoggedList.size() > 0){
                hoursLoggedList[0].End_Date_Time__c = System.now();
                Long dt1Long = hoursLoggedList[0].Start_Date_Time__c.getTime();
                Long dt2Long = hoursLoggedList[0].End_Date_Time__c.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Long minutes = (seconds / 60);
                Long hours = minutes / 60;
                Long days = hours / 24;
                hoursLoggedList[0].Time_Spent_d__c = days;
                hoursLoggedList[0].Time_Spent_h__c = math.mod(hours, 24);
                hoursLoggedList[0].Time_Spent_m__c = math.mod(minutes, 60);
                if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                    hoursLoggedList[0].Notes__c = notes;
                }
                update hoursLoggedList;
            }
            if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                CustomerOrderCtrl.calculateTechinicianHours(new Set<Id>{hoursLoggedList[0].Id}, null);
            }
            if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                //return getServiceJobs(BPUtility.getEncodedString(technicianId));
                return getServiceJob(recordId, technicianId);
            }else if(objectName == Constants.NAMESPACE + 'Task__c') {
                //return getTaskListWithTechnicianId(BPUtility.getEncodedString(technicianId));
                return getTask(recordId, technicianId);
            }
        }catch(Exception e){
            system.assert(false, e);
        }
        //return getServiceJobs(BPUtility.getEncodedString(technicianId));
        return getServiceJob(recordId, technicianId);
    }
    
    
    public static List<Hours_Logged__c> clockOFFTechnicianforAllActiveJobs(String technicianId){
        List<Hours_Logged__c> hoursLoggedList = [select Id, Start_Date_Time__c, End_Date_Time__c, Service_Order_Header__c, Technician__c 
                                                    from Hours_Logged__c
                                                    where Technician__c = :technicianId
                                                    AND Start_Date_Time__c != null
                                                    AND End_Date_Time__c = null];
                                                    
        return getcalculatedHoursLoggedList(hoursLoggedList);
    }
    
    
    public static List<Hours_Logged__c> clockOFFTaskforAllTechnician(String taskId){
        List<Hours_Logged__c> hoursLoggedList = [select Id, Start_Date_Time__c, End_Date_Time__c, Service_Order_Header__c, Technician__c 
                                                    from Hours_Logged__c
                                                    where Task__c = :taskId
                                                    AND Start_Date_Time__c != null
                                                    AND End_Date_Time__c = null];
                                                    
        return getcalculatedHoursLoggedList(hoursLoggedList);
    }
    
    public static List<Hours_Logged__c> getcalculatedHoursLoggedList(List<Hours_Logged__c> hoursLoggedList){
        for(Hours_Logged__c hoursLoggedRec : hoursLoggedList){
            if(hoursLoggedRec.End_Date_Time__c == null){
                hoursLoggedRec.End_Date_Time__c = System.now();
            }
            Long dt1Long = hoursLoggedRec.Start_Date_Time__c.getTime();
            Long dt2Long = hoursLoggedRec.End_Date_Time__c.getTime();
            Long milliseconds = dt2Long - dt1Long;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;
            hoursLoggedRec.Time_Spent_d__c = days;
            hoursLoggedRec.Time_Spent_h__c = math.mod(hours, 24);
            hoursLoggedRec.Time_Spent_m__c = math.mod(minutes, 60);
        }
        return hoursLoggedList;
    }
    
    
    @RemoteAction
    global static String getTaskList() {
        // Deprecated
        return null;
    }
    
    @RemoteAction
    global static String getTaskListWithTechnicianId(String technicianId) {
        technicianId = BPUtility.getDecodedString(technicianId);
        List<Task__c> taskList;
        if(String.isBlank(technicianId)){
            taskList = [select Id, Name__c,
                                    (select Id, Technician__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, 
                                        Technician__r.Active__c, Start_Date_Time__c, End_Date_Time__c, Time_Spent_d__c, 
                                        Time_Spent_h__c, Time_Spent_m__c, Is_Removed__c 
                                        from Hours_Logged__r 
                                        Where ( Start_Date_Time__c = TODAY
                                                OR End_Date_Time__c = TODAY)
                                        order by CreatedDate desc)
                            from Task__c order by Name__c]; // CreatedDate
        }else{
            taskList = [select Id, Name__c,
                                    (select Id, Technician__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, 
                                        Technician__r.Active__c, Start_Date_Time__c, End_Date_Time__c, Time_Spent_d__c, 
                                        Time_Spent_h__c, Time_Spent_m__c, Is_Removed__c 
                                        from Hours_Logged__r 
                                        Where Technician__c = :technicianId
                                            AND( Start_Date_Time__c = TODAY
                                                OR End_Date_Time__c = TODAY)
                                        order by CreatedDate desc)
                                    from Task__c order by Name__c]; // CreatedDate
        }
        
        List<TaskWrapper> taskWrapperList = new List<TaskWrapper>();
        for(Task__c taskObj : taskList){
            taskWrapperList.add(new TaskWrapper(taskObj, technicianId));
        }
        taskWrapperList.sort();
        return BPUtility.getEncodedString(system.JSON.serialize(taskWrapperList));
    }
    
    private static String getTask(String taskId, String technicianId) {
        List<Task__c> taskList;
        if(String.isBlank(technicianId)){
            taskList = [select Id, Name__c,
                                    (select Id, Technician__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, 
                                        Technician__r.Active__c, Start_Date_Time__c, End_Date_Time__c, Time_Spent_d__c, 
                                        Time_Spent_h__c, Time_Spent_m__c, Is_Removed__c 
                                        from Hours_Logged__r 
                                        Where ( Start_Date_Time__c = TODAY
                                                OR End_Date_Time__c = TODAY)
                                        order by CreatedDate desc)
                            from Task__c where Id = :taskId];
        }else{
            taskList = [select Id, Name__c,
                                    (select Id, Technician__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, 
                                        Technician__r.Active__c, Start_Date_Time__c, End_Date_Time__c, Time_Spent_d__c, 
                                        Time_Spent_h__c, Time_Spent_m__c, Is_Removed__c 
                                        from Hours_Logged__r 
                                        Where Technician__c = :technicianId
                                            AND( Start_Date_Time__c = TODAY
                                                OR End_Date_Time__c = TODAY)
                                        order by CreatedDate desc)
                                    from Task__c where Id = :taskId];
        }
        return BPUtility.getEncodedString(system.JSON.serialize(new TaskWrapper(taskList[0], technicianId)));
    }
    
    @RemoteAction
    global static String addEditTask(String taskId, String taskName) {
        taskId = BPUtility.getDecodedString(taskId);
        taskName = BPUtility.getDecodedString(taskName);
        
        Task__c taskObj = new Task__c();
        if(String.isNotBlank(taskId)){
            taskObj.Id = taskId;
        }
        taskObj.Name__c = taskName;
        upsert taskObj;
        //return getTaskListWithTechnicianId(null);
        return getTask(taskObj.Id, null);
    }
    

    @RemoteAction
    global static String deleteTask(String taskId) {
        taskId = BPUtility.getDecodedString(taskId);
        
        Task__c taskObj = new Task__c();
        taskObj.Id = taskId;
        delete taskObj;
        return getTaskListWithTechnicianId(null);
    }    
    
    @RemoteAction
    global static String getOtherTasks(String filterJSON) {
        filterJSON = BPUtility.getDecodedString(filterJSON);
        HoursLoggedFilterWrapper filterObj = (HoursLoggedFilterWrapper) system.JSON.deserialize(filterJSON, HoursLoggedFilterWrapper.class);
        
        String whereClause = 'where Task__c != null';
        /*if(filterObj != null) {
            if(filterObj.Id != null) {
                whereClause += 'AND Id =: filterObj.Id ';
            }
            if(filterObj.TechnicianId != null) {
                whereClause += 'AND Technician__c =: filterObj.Technician__c ';
            }
            if(filterObj.TaskId != null) {
                whereClause += 'AND Task__c =: filterObj.TaskId ';
            }
            if(filterObj.FromDate != null) {
                whereClause += 'AND Start_Date_Time__c =: Date.parse(filterObj.FromDate) ';
            }
            if(filterObj.ToDate != null) {
                whereClause += 'AND End_Date_Time__c =: Date.parse(filterObj.ToDate) ';
            }
        }*/
        
        
        if(filterObj != null) {
            if(String.isNotBlank(filterObj.Id)) {
                whereClause += ' AND Id = \''+ filterObj.Id + '\'';
            }
            if(String.isNotBlank(filterObj.TechnicianId)) {
                whereClause += ' AND Technician__c = \''+ filterObj.TechnicianId + '\'';
            }
            if(String.isNotBlank(filterObj.TaskId)) {
                whereClause += ' AND Task__c = \''+ filterObj.TaskId + '\'';
            }
            if(filterObj.FromDate != null) {
                DateTime strtDate = HomeSearchFilterInterface.getDateFromString(filterObj.FromDate);
                whereClause += ' AND Start_Date_Time__c >= '+ strtDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
            if(filterObj.ToDate != null) {
                DateTime endDate = HomeSearchFilterInterface.getDateFromString((filterObj.ToDate)).addDays(1);
                whereClause += ' AND End_Date_Time__c <= '+ endDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
        }
        
        String query = 'select Task__r.Name__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, '+
                         'Start_Date_Time__c, End_Date_Time__c, Time_Spent_h__c, Time_Spent_m__c from Hours_Logged__c ';
        query += whereClause + ' Order By Task__r.Name__c, Technician__r.Technician_Name__c, Start_Date_Time__c, End_Date_Time__c';
        List<Hours_Logged__c> hoursLoggedList = Database.query(query);
        List<TaskWrapper.OtherTaskWrapper> otherTaskList = new List<TaskWrapper.OtherTaskWrapper>();
        for(Hours_Logged__c hoursLoggedRec : hoursLoggedList){
            otherTaskList.add(new TaskWrapper.OtherTaskWrapper(hoursLoggedRec));
        }
        return BPUtility.getEncodedString(system.JSON.serialize(otherTaskList));
    }
   
    @RemoteAction
    global static String addEditTaskHoursLogged(String taskWrapperJSON) {
        taskWrapperJSON = BPUtility.getDecodedString(taskWrapperJSON);
        
        TaskWrapper.OtherTaskWrapper taskHoursLoggedObj = (TaskWrapper.OtherTaskWrapper) system.JSON.deserialize(taskWrapperJSON, TaskWrapper.OtherTaskWrapper.class);
        Hours_Logged__c hoursLoggedRec = setHoursLoggedField(taskHoursLoggedObj);
        
        if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Hours_Logged__c> existingHoursLoggedList = [Select Id from Hours_Logged__c where Technician__c =: hoursLoggedRec.Technician__c
                                                            AND (Start_Date_Time__c =: hoursLoggedRec.Start_Date_Time__c
                                                                   OR End_Date_Time__c =: hoursLoggedRec.End_Date_Time__c) 
                                                            AND Id <>: hoursLoggedRec.Id];
        if(existingHoursLoggedList.size() > 0) {
            return BPUtility.getEncodedString('[{"HasError" : true, "ErrorMsg" : "' + Label.Payroll_Already_exists_error + '"}]');
        } else {
            List<Hours_Logged__c> hoursLoggedList = getcalculatedHoursLoggedList(new List<Hours_Logged__c>{hoursLoggedRec});
            upsert hoursLoggedList;
            
            HoursLoggedFilterWrapper hrsLogObj = new HoursLoggedFilterWrapper();
            hrsLogObj.Id = hoursLoggedList[0].Id;
            return getOtherTasks(BPUtility.getEncodedString(system.JSON.serialize(hrsLogObj)));
        }
    }
    
    private static Hours_Logged__c setHoursLoggedField(TaskWrapper.OtherTaskWrapper hrsLoggedObj) {
        Hours_Logged__c hoursLoggedRec = new Hours_Logged__c();
        hoursLoggedRec.Id = hrsLoggedObj.Id;
        hoursLoggedRec.Technician__c = hrsLoggedObj.TechId;
        hoursLoggedRec.Task__c = hrsLoggedObj.TaskId;
        
        DateTime dtValue = HomeSearchFilterInterface.getDateFromString(hrsLoggedObj.StartDate);
        hoursLoggedRec.Start_Date_Time__c = createDateTimeFromStr(dtValue, hrsLoggedObj.StartTime);
        hoursLoggedRec.End_Date_Time__c = createDateTimeFromStr(dtValue, hrsLoggedObj.EndTime);
        return hoursLoggedRec;
    }
    
    @RemoteAction
    global static String deleteTaskHoursLogged(String hrsLogId, String hrsLoggedFilterJSON) {
        hrsLogId = BPUtility.getDecodedString(hrsLogId);
        
        if(String.isNotBlank(hrsLogId)) {
            delete new Hours_Logged__c(Id = hrsLogId);
        }
        
        HoursLoggedFilterWrapper hrsLogObj = new HoursLoggedFilterWrapper();
        return getOtherTasks(hrsLoggedFilterJSON);
    }
    
    private static DateTime getConvertedDateTime(String strDate, String strTime){
        
        String stringDateTime = '';
        stringDateTime += strDate;
        stringDateTime += ' ' + strTime.substring(0, strTime.length()-3);
        String strTimePeriod = ' ' + strTime.substring(strTime.length()-2, strTime.length());
        stringDateTime += strTimePeriod;
        //system.assert(false, stringDateTime);
        return DateTime.parse(stringDateTime);  
    }
    
    private static DateTime createDateTimeFromStr(DateTime dtValue, String timeStr) {
        if(String.isNotBlank(timeStr)) {
            List<String> timeSubStrList = timeStr.split(' ');
            if(timeSubStrList.size() > 1) {
                Integer hoursValue = Integer.valueOf(timeSubStrList[0].split(':')[0]);
                hoursValue = (hoursValue == 12) ? (hoursValue - 12) : hoursValue; 
                dtValue = dtValue.addHours(hoursValue);
                dtValue = dtValue.addMinutes(Integer.valueOf(timeSubStrList[0].split(':')[1]));
                
                if(timeSubStrList[1] == 'PM') {
                    dtValue = dtValue.addHours(12);
                }
            }
        }
        return dtValue;
    }
    
    public class HoursLoggedFilterWrapper {
        public String Id;
        public String TechnicianId;
        public String TaskId;
        public String FromDate;
        public String ToDate;
    }
}