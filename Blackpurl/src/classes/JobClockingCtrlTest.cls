@isTest
private class JobClockingCtrlTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
    	Technician__c technicianRec = TestDataFactory.createTechnician();
    	CO_Header__c coHeaderRec = TestDataFactory.createCoHeader(customer.Id);
    	Service_Order_Header__c soHeaderRec = TestDataFactory.createSOHeader(coHeaderRec.Id);
    	soHeaderRec.Work_Status__c = 'New';
    	update soHeaderRec;
    	
    	Task__c taskRec = TestDataFactory.createTask();
    	Hours_Logged__c hoursLoggedRec = TestDataFactory.createHoursLogged(technicianRec.Id, soHeaderRec.Id, taskRec.Id);
    	Payroll_Time__c payrollTimeRec = TestDataFactory.createPayrollTime(technicianRec.Id);
    }
    
    @isTest
    private static void testConstructor(){
    	Test.startTest();
    	JobClockingCtrl jobClockingCtrl = new JobClockingCtrl();
    	JobClockingCtrl jobClockingCtrlwithNewHomePage = new JobClockingCtrl(new NewHomePageCtrl());
    	Technician__c technician = [SELECT Technician_Name__c FROM Technician__c LIMIT 1];
    	system.assertEquals(technician.Technician_Name__c, 'Test Name');
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetServiceJobs(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	String result = JobClockingCtrl.getServiceJobs(BPUtility.getEncodedString(technician.Id));
    	result = BPUtility.getDecodedString(result);
    	List<JobClockingWrapper> jobClockingWrapperList = new List<JobClockingWrapper>((List<JobClockingWrapper>)json.deserialize(result, List<JobClockingWrapper>.class));
    	system.assertEquals(jobClockingWrapperList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetServiceJobsForMultipleJobs(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Account customer = [SELECT Id FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	CO_Header__c coHeaderRec = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Service_Order_Header__c soHeaderRec1 = TestDataFactory.createSOHeader(coHeaderRec.Id);
    	soHeaderRec1.Work_Status__c = 'Ready';
    	update soHeaderRec1;
    	Service_Order_Header__c soHeaderRec2 = TestDataFactory.createSOHeader(coHeaderRec.Id);
    	soHeaderRec2.Work_Status__c = 'Ready';
    	update soHeaderRec2;
    	Technician__c technicianRec = TestDataFactory.createTechnician();
    	Hours_Logged__c hoursLoggedRec1 = TestDataFactory.createHoursLogged(null, soHeaderRec1.Id, null);
    	Hours_Logged__c hoursLoggedRec2 = TestDataFactory.createHoursLogged(technicianRec.Id, soHeaderRec2.Id, null);
    	String result = JobClockingCtrl.getServiceJobs(BPUtility.getEncodedString(technician.Id));
    	result = BPUtility.getDecodedString(result);
    	List<JobClockingWrapper> jobClockingWrapperList = new List<JobClockingWrapper>((List<JobClockingWrapper>)json.deserialize(result, List<JobClockingWrapper>.class));
    	system.assertEquals(jobClockingWrapperList.size(), 3);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetServiceJobsWithTechnicianIdNull(){
    	Test.startTest();
    	String result = JobClockingCtrl.getServiceJobs(BPUtility.getEncodedString(null));
    	result = BPUtility.getDecodedString(result);
    	List<JobClockingWrapper> jobClockingWrapperList = new List<JobClockingWrapper>((List<JobClockingWrapper>)json.deserialize(result, List<JobClockingWrapper>.class));
    	system.assertEquals(jobClockingWrapperList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTechnicianList(){
    	Test.startTest();
    	Service_Order_Header__c soHeaderRec = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	String result = BPUtility.getDecodedString(JobClockingCtrl.getTechnicianList(BPUtility.getEncodedString(soHeaderRec.Id)));
    	List<SOHeaderWrapper.TechnicianWrapper> technicianObjList = new List<SOHeaderWrapper.TechnicianWrapper>((List<SOHeaderWrapper.TechnicianWrapper>)json.deserialize(result, List<SOHeaderWrapper.TechnicianWrapper>.class));
    	system.assertEquals(technicianObjList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testAssignTechnician(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Service_Order_Header__c soHeaderRec = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	String result = BPUtility.getDecodedString(JobClockingCtrl.assignTechnician(BPUtility.getEncodedString(soHeaderRec.Id), BPUtility.getEncodedString(technician.Id), BPUtility.getEncodedString(null)));
    	JobClockingWrapper jobClockingWrapper = (JobClockingWrapper)json.deserialize(result, JobClockingWrapper.class);
    	system.assertEquals('Test001', jobClockingWrapper.CustomerName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testRemoveTechnician(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Service_Order_Header__c soHeaderRec = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	Hours_Logged__c hoursLogged = [SELECT Start_Date_Time__c FROM Hours_Logged__c LIMIT 1];
    	hoursLogged.Start_Date_Time__c = null;
    	update hoursLogged;
    	String result = BPUtility.getDecodedString(JobClockingCtrl.removeTechnician(BPUtility.getEncodedString(soHeaderRec.Id), BPUtility.getEncodedString(technician.Id), BPUtility.getEncodedString(null)));
    	JobClockingWrapper jobClockingWrapper = (JobClockingWrapper)json.deserialize(result, JobClockingWrapper.class);
    	system.assertEquals('Test001', jobClockingWrapper.CustomerName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetHoursLoggedBySOHeaderId(){
    	Test.startTest();
    	Service_Order_Header__c soHeaderRec = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	String result = BPUtility.getDecodedString(JobClockingCtrl.getHoursLoggedBySOHeaderId(BPUtility.getEncodedString(soHeaderRec.Id)));
    	List<JobClockingWrapper.HoursLoggedInfo> sortedHoursLoggedInfoList = new List<JobClockingWrapper.HoursLoggedInfo>((List<JobClockingWrapper.HoursLoggedInfo>)json.deserialize(result,List<JobClockingWrapper.HoursLoggedInfo>.class));
    	system.assertEquals(1, sortedHoursLoggedInfoList.size());
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetPayrollEntryForTechnician(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	String result = BPUtility.getDecodedString(JobClockingCtrl.getPayrollEntryForTechnician(BPUtility.getEncodedString(technician.Id)));
    	system.assertEquals ('ru', result.substring(18, 20));
    	Test.stopTest();
    }
    
    @isTest
    private static void testSetPayrollForTechnician(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Payroll_Time__c payrollTime = [SELECT Id, Technician__c, Technician__r.Technician_Name__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, Start_Date__c, End_Date__c, Formatted_Total_Time__c  FROM Payroll_Time__c LIMIT 1];
    	PayrollWrapper payrollWrapper = new PayrollWrapper(payrollTime);
    	payrollWrapper.IsClockedOn = true;
    	String result = BPUtility.getDecodedString(JobClockingCtrl.setPayrollForTechnician(BPUtility.getEncodedString(json.serialize(payrollWrapper)), BPUtility.getEncodedString(technician.Id)));
    	system.assertEquals ('ru', result.substring(18, 20));
    	Test.stopTest();
    }
    
    @isTest
    private static void testSetPayrollEntryForTechnician(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	String result = BPUtility.getDecodedString(JobClockingCtrl.setPayrollEntryForTechnician(BPUtility.getEncodedString(technician.Id)));
    	system.assertEquals ('ru', result.substring(18, 20));
    	Test.stopTest();
    }
    
    @isTest
    private static void testClockONTechnicianForSOHeader(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Service_Order_Header__c soHeaderRec = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	Hours_Logged__c hoursLogged = [SELECT Start_Date_Time__c FROM Hours_Logged__c LIMIT 1];
    	hoursLogged.Start_Date_Time__c = null;
    	update hoursLogged;
    	String result = BPUtility.getDecodedString(JobClockingCtrl.clockONTechnician(BPUtility.getEncodedString(soHeaderRec.Id), BPUtility.getEncodedString(technician.Id)));
    	List<JobClockingWrapper> jobClockingWrapperList = new List<JobClockingWrapper>((List<JobClockingWrapper>)json.deserialize(result, List<JobClockingWrapper>.class));
    	system.assertEquals('Test001', jobClockingWrapperList[0].CustomerName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testClockONTechnicianForTask(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Task__c task = [SELECT Id FROM Task__c LIMIT 1];
    	Hours_Logged__c hoursLogged = [SELECT Start_Date_Time__c FROM Hours_Logged__c LIMIT 1];
    	hoursLogged.Start_Date_Time__c = null;
    	update hoursLogged;
    	String result = BPUtility.getDecodedString(JobClockingCtrl.clockONTechnician(BPUtility.getEncodedString(task.Id), BPUtility.getEncodedString(technician.Id)));
    	List<JobClockingWrapper> jobClockingWrapperList = new List<JobClockingWrapper>((List<JobClockingWrapper>)json.deserialize(result, List<JobClockingWrapper>.class));
    	system.assertEquals(1, jobClockingWrapperList.size());
    	Test.stopTest();
    }
    
    @isTest
    private static void testClockOFFTechnicianWithNotesForSOHeader(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Service_Order_Header__c soHeaderRec = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	Notes__c notes = TestDataFactory.createNotes();
    	String result = BPUtility.getDecodedString(JobClockingCtrl.clockOFFTechnicianWithNotes(BPUtility.getEncodedString(soHeaderRec.Id), BPUtility.getEncodedString(technician.Id), BPUtility.getEncodedString(notes.Id)));
    	JobClockingWrapper jobClockingWrapper = (JobClockingWrapper)json.deserialize(result, JobClockingWrapper.class);
    	system.assertEquals('Test001', jobClockingWrapper.CustomerName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testClockOFFTechnicianWithNotesForTask(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Task__c task = [SELECT Id FROM Task__c LIMIT 1];
    	Notes__c notes = TestDataFactory.createNotes();
    	String result = BPUtility.getDecodedString(JobClockingCtrl.clockOFFTechnicianWithNotes(BPUtility.getEncodedString(task.Id), BPUtility.getEncodedString(technician.Id), BPUtility.getEncodedString(notes.Id)));
    	JobClockingWrapper jobClockingWrapper = (JobClockingWrapper)json.deserialize(result, JobClockingWrapper.class);
    	system.assertEquals(null, jobClockingWrapper.CustomerName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testClockOFFTechnicianforAllActiveJobs(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	List<Hours_Logged__c> hoursLoggedList = new List<Hours_Logged__c>(JobClockingCtrl.clockOFFTechnicianforAllActiveJobs(technician.Id));
    	system.assertEquals(hoursLoggedList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testClockOFFTaskforAllTechnician(){
    	Test.startTest();
    	Task__c task = [SELECT Id FROM Task__c LIMIT 1];
    	List<Hours_Logged__c> hoursLoggedList = new List<Hours_Logged__c>(JobClockingCtrl.clockOFFTaskforAllTechnician(task.Id));
    	system.assertEquals(hoursLoggedList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTaskListWithTechnicianId(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	String result = BPUtility.getDecodedString(JobClockingCtrl.getTaskListWithTechnicianId(BPUtility.getEncodedString(technician.Id)));
    	List<TaskWrapper> taskWrapperList = new List<TaskWrapper>((List<TaskWrapper>)json.deserialize(result, List<TaskWrapper>.class));
    	system.assertEquals(taskWrapperList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testAddEditTask(){
    	Test.startTest();
    	Task__c task = [SELECT Id FROM Task__c LIMIT 1];
    	String result = BPUtility.getDecodedString(JobClockingCtrl.addEditTask(BPUtility.getEncodedString(task.Id), BPUtility.getEncodedString('Test Task')));
    	TaskWrapper taskWrapper = (TaskWrapper)json.deserialize(result, TaskWrapper.class);
    	system.assertEquals(taskWrapper.Name, 'Test Task');
    	Test.stopTest();
    }
    
    @isTest
    private static void testDeleteTask(){
    	Test.startTest();
    	Task__c task = [SELECT Id FROM Task__c LIMIT 1];
    	String result = BPUtility.getDecodedString(JobClockingCtrl.deleteTask(BPUtility.getEncodedString(task.Id)));
    	List<TaskWrapper> taskWrapperList = new List<TaskWrapper>((List<TaskWrapper>)json.deserialize(result, List<TaskWrapper>.class));
    	system.assertEquals(taskWrapperList.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetOtherTasks(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Task__c task = [SELECT Id FROM Task__c LIMIT 1];
    	Hours_Logged__c hoursLogged = [SELECT Id FROM Hours_Logged__c LIMIT 1];
    	JobClockingCtrl.HoursLoggedFilterWrapper hoursLoggedFilterWrapper = new JobClockingCtrl.HoursLoggedFilterWrapper();
    	hoursLoggedFilterWrapper.Id = hoursLogged.Id;
    	hoursLoggedFilterWrapper.TechnicianId = technician.Id;
    	hoursLoggedFilterWrapper.TaskId = task.Id;
		String filterJSON = json.serialize(hoursLoggedFilterWrapper);
		String result = BPUtility.getDecodedString(JobClockingCtrl.getOtherTasks(BPUtility.getEncodedString(filterJSON)));
		List<TaskWrapper.OtherTaskWrapper> otherTaskList = new List<TaskWrapper.OtherTaskWrapper>((List<TaskWrapper.OtherTaskWrapper>)json.deserialize(result, List<TaskWrapper.OtherTaskWrapper>.class));
		system.assertEquals(otherTaskList.size(), 1);		
    	Test.stopTest();
    }
    
     @isTest
     private static void testAddEditTaskHoursLogged(){
     	Test.startTest();
     	Hours_Logged__c hoursLogged = [SELECT Id, Technician__c, Task__c, Task__r.Name__c, Technician__r.First_Name__c, Technician__r.Last_Name__c, Start_Date_Time__c, End_Date_Time__c, Time_Spent_h__c, Time_Spent_m__c FROM Hours_Logged__c LIMIT 1];
     	TaskWrapper.OtherTaskWrapper taskHoursLoggedObj = new TaskWrapper.OtherTaskWrapper(hoursLogged);
     	String taskWrapperJSON = json.serialize(taskHoursLoggedObj);
     	String result = BPUtility.getDecodedString(JobClockingCtrl.addEditTaskHoursLogged(BPUtility.getEncodedString(taskWrapperJSON)));
     	List<TaskWrapper.OtherTaskWrapper> otherTaskList = new List<TaskWrapper.OtherTaskWrapper>((List<TaskWrapper.OtherTaskWrapper>)json.deserialize(result, List<TaskWrapper.OtherTaskWrapper>.class));
		system.assertEquals(otherTaskList.size(), 1);
     	Test.stopTest();
     }
     
     @isTest
     private static void testDeleteTaskHoursLogged(){
     	Test.startTest();
     	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	Task__c task = [SELECT Id FROM Task__c LIMIT 1];
    	Hours_Logged__c hoursLogged = [SELECT Id FROM Hours_Logged__c LIMIT 1];
    	JobClockingCtrl.HoursLoggedFilterWrapper hoursLoggedFilterWrapper = new JobClockingCtrl.HoursLoggedFilterWrapper();
    	hoursLoggedFilterWrapper.Id = hoursLogged.Id;
    	hoursLoggedFilterWrapper.TechnicianId = technician.Id;
    	hoursLoggedFilterWrapper.TaskId = task.Id;
		String hrsLoggedFilterJSON = json.serialize(hoursLoggedFilterWrapper);
		String result = BPUtility.getDecodedString(JobClockingCtrl.deleteTaskHoursLogged(BPUtility.getEncodedString(hoursLogged.Id), BPUtility.getEncodedString(hrsLoggedFilterJSON)));
     	List<TaskWrapper.OtherTaskWrapper> otherTaskList = new List<TaskWrapper.OtherTaskWrapper>((List<TaskWrapper.OtherTaskWrapper>)json.deserialize(result, List<TaskWrapper.OtherTaskWrapper>.class));
		system.assertEquals(otherTaskList.size(), 0);
     	Test.stopTest();
     }
     
     @isTest
     private static void testJobClockingWrapperSorting(){
     	Test.startTest();
     	Service_Order_Header__c serviceJobRec = [SELECT Id, Work_Status__c, Name__c, CO_Header__r.Name, CO_Header__c, SO_Concern__c, Transaction_Type__r.Code_Label__c, Customer_Owned_Unit__r.Year__c, Customer_Owned_Unit__r.Make_Name__c, Customer_Owned_Unit__r.Model_Name__c, Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c, CO_Header__r.Customer_Name__c, CO_Header__r.CreatedDate FROM Service_Order_Header__c LIMIT 1]; 
     	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
     	JobClockingWrapper jobClockingWrapper1 = new JobClockingWrapper(serviceJobRec, technician.Id);
     	JobClockingWrapper jobClockingWrapper2 = new JobClockingWrapper(serviceJobRec, technician.Id);
     	
     	List<JobClockingWrapper> jobClockingWrapperList = new List<JobClockingWrapper>();
     	jobClockingWrapperList.add(jobClockingWrapper1);
     	jobClockingWrapperList.add(jobClockingWrapper2);
     	jobClockingWrapperList.sort();
     	
     	system.assertEquals(2, jobClockingWrapperList.size());
     	Test.stopTest();
     }
     
     @isTest
     private static void testJobClockingWrapperSortingWithJobServiceClockedOn(){
     	Test.startTest();
     	Service_Order_Header__c serviceJobRec = [SELECT Id, Work_Status__c, Name__c, CO_Header__r.Name, CO_Header__c, SO_Concern__c, Transaction_Type__r.Code_Label__c, Customer_Owned_Unit__r.Year__c, Customer_Owned_Unit__r.Make_Name__c, Customer_Owned_Unit__r.Model_Name__c, Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c, CO_Header__r.Customer_Name__c, CO_Header__r.CreatedDate FROM Service_Order_Header__c LIMIT 1]; 
     	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
     	JobClockingWrapper jobClockingWrapper1 = new JobClockingWrapper(serviceJobRec, null);
     	JobClockingWrapper jobClockingWrapper2 = new JobClockingWrapper(serviceJobRec, null);
     	jobClockingWrapper1.IsServiceJobClocked = true;
     	jobClockingWrapper2.IsServiceJobClocked = true;
     	List<JobClockingWrapper> jobClockingWrapperList = new List<JobClockingWrapper>();
     	jobClockingWrapperList.add(jobClockingWrapper1);
     	jobClockingWrapperList.add(jobClockingWrapper2);
     	jobClockingWrapperList.sort();
     	
     	system.assertEquals(2, jobClockingWrapperList.size());
     	Test.stopTest();
     }
}