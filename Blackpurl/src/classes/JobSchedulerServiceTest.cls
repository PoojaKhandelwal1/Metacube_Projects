@isTest
private class JobSchedulerServiceTest {
    @testsetup
    private static void setup(){
    	Account customerRec = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
		Customer_Owned_Unit__c unitRec = TestDataFactory.createCustomerOwnedUnit(customerRec.Id, 'VIN001');
		Event eventRec1 = TestDataFactory.createEventForAfternoon(customerRec.Id, unitRec.Id);
		eventRec1.Type = 'Appointment';
		eventRec1.StartDateTime = HomeSearchFilterInterface.getDateFromString('12/03/1997');
		update eventRec1;
		Event eventRec2 = TestDataFactory.createEventForAfternoon(customerRec.Id, unitRec.Id);
    }
    
    @isTest
    private static void testGetTechnicianListForSpecificDay(){
    	Test.startTest();
		List<TechnicianDetailWrapper> technicianDetailWrapperList = new List<TechnicianDetailWrapper>(JobSchedulerService.getTechnicianListForSpecificDay('12/03/1997'));
		system.assertEquals(technicianDetailWrapperList.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateAppointment(){
    	Test.startTest();
    	List<Event> eventRec = new List<Event>([SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Afternoon']);
    	eventRec[0].StartDateTime = HomeSearchFilterInterface.getDateFromString('12/03/1997');
    	update eventRec;
    	AppointmentWrapper appWrapper1 = new AppointmentWrapper(eventRec[0], true);
    	AppointmentWrapper appWrapper2 = new AppointmentWrapper(eventRec[1], true);
    	List<AppointmentWrapper> appointmentWrapperList = new List<AppointmentWrapper>();
    	appointmentWrapperList.add(appWrapper1);
    	appointmentWrapperList.add(appWrapper2);
    	String appointmentObjStr = json.serialize(appointmentWrapperList);
    	JobSchedulerService.updateAppointment(appointmentObjStr);
    	List<Event> eventRecUpdated = new List<Event>([SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Afternoon']);
    	system.assertEquals(eventRecUpdated[0].Subject, 'Test Event');
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetUnassignedAppointmentForSpecificDay(){
    	Test.startTest();
    	List<AppointmentWrapper> appointmentWrapperList = new List<AppointmentWrapper>(JobSchedulerService.getUnassignedAppointmentForSpecificDay('12/03/1997'));
    	system.assertEquals(appointmentWrapperList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testCreateCOWithServiceJob(){
    	Test.startTest();
    	Account customer = [SELECT Id FROM Account LIMIT 1];
    	List<Event> eventRec = new List<Event>([SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Afternoon']);
    	eventRec[0].CO_Header__c = null;
    	update eventRec;
    	AppointmentWrapper appWrapper = new AppointmentWrapper(eventRec[0], true);
    	String appointmentObjStr = json.serialize(appWrapper);
    	Id result = (Id)JobSchedulerService.createCOWithServiceJob(appointmentObjStr);
    	system.assertEquals(true, result.getSObjectType().getDescribe().getName().contains('CO_Header__c'));
    	Test.stopTest();
    }
		
	@isTest
	private static void testGetAssignedAppointmentForSpecificDay(){
		Test.startTest();
		Technician__c technician = TestDataFactory.createTechnician();
		Map<String, List<AppointmentWrapper>> result = new Map<String, List<AppointmentWrapper>>(JobSchedulerService.getAssignedAppointmentForSpecificDay('12/03/1997', technician.Id));
		system.assertEquals(result.size(), 0);
		Test.stopTest();
	}  
}